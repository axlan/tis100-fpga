import compiler

import random

OUT_TV = 'data/registers_tv.mem'
NUM_TESTS = 100
random.seed(9001)

OP_WRITE = 1
OP_SWP = 2
OP_SAV = 3


class TestRegisters:
    def __init__(self):
        self.acc = 0
        self.bak = 0

    def update(self, instr, input_val):
        if instr == OP_SWP:
            tmp = self.acc
            self.acc = self.bak
            self.bak = tmp
        elif instr == OP_SAV:
            self.bak = self.acc
        elif instr == OP_WRITE:
            self.acc = input_val

def get_tv_line(instr, input_val, acc):
    combined = f'{instr:02b}_'
    combined += f'{compiler.truncate_const(input_val):011b}_'
    combined += f'{compiler.truncate_const(acc):011b}'
    return combined

def main():

    test_registers = TestRegisters()
    with open(OUT_TV, 'w') as fd:
        for i in range(NUM_TESTS):
            op = random.randint(0, 3)
            input_val = random.randint(-compiler.CONST_MAX, compiler.CONST_MAX)
            test_registers.update(op, input_val)
            fd.write(get_tv_line(op, input_val, test_registers.acc))
            if i != NUM_TESTS - 1:
                fd.write('\n')

if __name__ == "__main__":
    main()
