# tp2b: Too Painful to Build

> **"An FSM-based Esoteric Programming Language that destroys your brain with just two characters."**

**tp2b** is an Esoteric Programming Language that combines the minimalist philosophy of Brainfuck with the complexity of a **Finite State Machine**. Implemented directly in x86-64 Assembly, it boasts an extreme level of coding difficulty.

In most languages, a command always performs the same action. But not in **tp2b**.
The two commands, `(` and `L`, perform 4 completely different actions depending on the current **FSM State ($S_0 \sim S_3$)**.

1.  **Unpredictability:** The same `(` command might move the pointer, start a loop, or skip input depending on when it is executed.
2.  **Forced Transitions:** Executing a command forces the state to change. You must insert useless "state-changing" commands just to perform the action you actually want.
3.  **Debugging Hell:** You must mentally track not only the code's position but also the invisible FSM state.

---

## Architecture

### 1. States
The language has 4 cyclic states.

| State | Name | Main Role |
| :--- | :--- | :--- |
| **$S_0$** | **Pointer Mode** | Move Data Pointer (P) |
| **$S_1$** | **Value Mode** | Manipulate Value and Conditional Skip |
| **$S_2$** | **Loop Mode** | Loop Control (Start/End) |
| **$S_3$** | **IO/Reset Mode** | Output and FSM Initialization |

### 2. Commands

| Command | Current State | Action | Next State | Remarks |
| :--- | :--- | :--- | :--- | :--- |
| **`(`** | $S_0$ | $P \leftarrow P + 1$ | $\rightarrow S_1$ | Increment Pointer |
| | $S_1$ | **IF $*P == 0$ SKIP** | $\rightarrow S_2$ | If 0, skip to matching `L` |
| | $S_2$ | **Loop Start `[`** | $\rightarrow S_0$ | If 0, skip loop |
| | $S_3$ | FSM Reset | $\rightarrow S_0$ | Initialize State |
| **`L`** | $S_0$ | $P \leftarrow P - 1$ | $\rightarrow S_2$ | Decrement Pointer |
| | $S_1$ | $*P \leftarrow *P + 1$ | $\rightarrow S_3$ | Increment Value by 1 |
| | $S_2$ | **Loop End `]`** | $\rightarrow S_1$ | If not 0, jump to start |
| | $S_3$ | **Output Char** | $\rightarrow S_0$ | Output current value (ASCII) |

---

## Build & Run

This project runs on Linux x86-64 environments (or Windows WSL). `nasm` and `ld` are required.

### Prerequisites
```bash
sudo apt update
sudo apt install nasm
```

### Build
```bash
# 1. Assemble
nasm -f elf64 tp2b.asm -o tp2b.o

# 2. Link
ld tp2b.o -o tp2b
```

### Run
Execute by redirecting a file containing the code into the program.
```bash
# Run File
./tp2b < hello_world.tp
```

---

## Coding Strategy

Because tp2b has a property where it skips code in states $S_1$ and $S_2$ if the value is 0, coding on uninitialized memory is extremely difficult. To overcome this, we use the **Anchor Strategy**.

1.  **Set Anchor:** Make the value of Cell 0 into `1` to establish a "Safe Zone".
2.  **Manipulate Value:** Move to Cell 1 to manipulate values. When a loop check is required, move back to Cell 0 (value 1) to prevent the skip logic.
3.  **Initialize:** After outputting, you must return the pointer to Cell 0 ($P=0, S_0$) to prepare for the next character.

---

## Python Generators

Since writing code manually is nearly impossible for humans, Python generators are provided.

*   `hello.py`: "Hello, World!" code generator

***

# tp2b: Too Painful to Build

> **"단 두 개의 문자로 뇌를 파괴하는 FSM 기반 난해한 프로그래밍 언어"**

**tp2b**는 Brainfuck의 최소주의 철학에 **Finite State Machine**의 복잡성을 결합한 Esoteric Programming Language입니다. x86-64 Assembly로 직접 구현되었으며, 극한의 코딩 난이도를 자랑합니다.

대부분의 언어에서 명령어는 항상 같은 동작을 수행합니다. 하지만 **tp2b**에서는 아닙니다.
단 두 개의 명령어 `(`와 `L`은 현재의 **FSM 상태($S_0 \sim S_3$)** 에 따라 전혀 다른 4가지 동작을 수행합니다.

1.  **예측 불허:** 같은 `(`가 어떤 때는 포인터를 옮기고, 어떤 때는 루프를 시작하며, 어떤 때는 입력을 무시(Skip)합니다.
2.  **강제 전이:** 명령을 실행하면 다음 상태가 강제로 변경됩니다. 원하는 동작을 하려면 불필요한 '상태 변경용' 명령을 끼워 넣어야 합니다.
3.  **디버깅 지옥:** 코드의 위치뿐만 아니라 보이지 않는 FSM 상태까지 머릿속으로 추적해야 합니다.

---

## Architecture

### 1. 상태 (States)
언어는 4가지 순환 상태를 가집니다.

| 상태 | 이름 | 주요 역할 |
| :--- | :--- | :--- |
| **$S_0$** | **Pointer Mode** | 데이터 포인터(P) 이동 |
| **$S_1$** | **Value Mode** | 값 조작 및 조건부 건너뛰기(Skip) |
| **$S_2$** | **Loop Mode** | 루프 제어 (Start/End) |
| **$S_3$** | **IO/Reset Mode** | 출력 및 FSM 초기화 |

### 2. 명령어 (Commands)

| 명령 | 현재 상태 | 동작 (Action) | 다음 상태 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **`(`** | $S_0$ | $P \leftarrow P + 1$ | $\rightarrow S_1$ | 포인터 증가 |
| | $S_1$ | **IF $*P == 0$ SKIP** | $\rightarrow S_2$ | 0이면 짝 `L`까지 건너뜀 |
| | $S_2$ | **Loop Start `[`** | $\rightarrow S_0$ | 0이면 루프 건너뜀 |
| | $S_3$ | FSM Reset | $\rightarrow S_0$ | 상태 초기화 |
| **`L`** | $S_0$ | $P \leftarrow P - 1$ | $\rightarrow S_2$ | 포인터 감소 |
| | $S_1$ | $*P \leftarrow *P + 1$ | $\rightarrow S_3$ | 값 1 증가 |
| | $S_2$ | **Loop End `]`** | $\rightarrow S_1$ | 0이 아니면 루프 시작으로 |
| | $S_3$ | **Output Char** | $\rightarrow S_0$ | 현재 값 ASCII 출력 |

---

## Build & Run

이 프로젝트는 Linux x86-64 환경(또는 Windows WSL)에서 동작합니다. `nasm`과 `ld`가 필요합니다.

### 필수 요구 사항
```bash
sudo apt update
sudo apt install nasm
```

### Build
```bash
# 1. Assemble
nasm -f elf64 tp2b.asm -o tp2b.o

# 2. Link
ld tp2b.o -o tp2b
```

### Run
코드가 담긴 파일을 입력으로 Redirect하여 실행합니다.
```bash
# Run File
./tp2b < hello_world.tp
```

---

## Coding Strategy

tp2b는 값이 0일 때 $S_1, S_2$ 상태에서 코드를 건너뛰는(Skip) 성질 때문에, 초기화되지 않은 메모리에서 코딩하기 매우 어렵습니다. 이를 극복하기 위해 **앵커 전략**을 사용합니다.

1.  **앵커 설정:** 0번 셀의 값을 1로 만들어 "안전 지대"를 확보합니다.
2.  **값 조작:** 1번 셀로 이동하여 값을 조작하고, 루프 검사가 필요할 때 0번 셀(값 1)로 돌아와 Skip을 방지합니다.
3.  **초기화:** 출력 후에는 반드시 포인터를 0번으로 되돌려($P=0, S_0$) 다음 글자를 준비합니다.

---

## Python Generators

사람이 직접 코드를 짜는 것은 불가능에 가깝기 때문에, 파이썬 생성기를 제공합니다.

*   `hello.py`: "Hello, World!" 코드 생성기
