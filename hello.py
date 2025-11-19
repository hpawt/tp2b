import subprocess
import os
import sys

def gen_hello_world():
    print("=== tp2b: Hello World ===")
    
    filename = "hello_world.tp"
    target_str = "Hello, World!"
    
    # 1. Setup Anchor (Mem[0]=1, Mem[1]=1)
    # State: P=0, S=S0
    full_code = "(L(LLL("
    current_val = 1 
    
    print(f"[Generating] \"{target_str}\"")
    
    for char in target_str:
        target_val = ord(char)
        diff = (target_val - current_val) % 256
        
        # 2. Increment Pattern (Inc P1, Return P0)
        # ( : S0->S1 (P=1)
        # L : S1->S3 (Val++)
        # ( : S3->S0 (Reset)
        # L : S0->S2 (P=0)
        # ( : S2->S0 (Mem[0]=1 -> S0 state maintained)
        inc_pattern = "(L(L("
        
        # 3. Print Pattern (Output P1, Return P0)
        # ( : S0->S1 (P=1)
        # L : S1->S3 (Val++)
        # L : S3->S0 (Output)
        # L : S0->S2 (P=0)
        # ( : S2->S0 (Pass -> S0 state maintained)
        out_pattern = "(LLL("
        
        if diff > 0:
            full_code += inc_pattern * (diff - 1)
            full_code += out_pattern
        else:
            full_code += inc_pattern * 255 + out_pattern
            
        current_val = target_val

    # 4. Clean Exit Padding
    full_code += "\n" * 100
    
    with open(filename, "w") as f:
        f.write(full_code)
        
    print(f"Code Generation Completed: {len(full_code)} bytes")
    print("Running...")

    try:
        cmd = f'bash -c "./tp2b < {filename} && echo"'
        res = subprocess.run(cmd, shell=True, capture_output=True)
        
        stdout = res.stdout.decode('utf-8', errors='replace')
        stderr = res.stderr.decode('utf-8', errors='replace')
        
        print(f"\n[Result]:\n{stdout}")
        
        if "Segmentation fault" in stderr:
            print("Segfault Occurred")
        else:
            print("It works! No Segfault.")
            
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    gen_hello_world()