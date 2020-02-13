import random

import compiler

TEST_COE = 'data/test_opcodes.coe'
OUT_TV = 'data/instr_rom_tv.mem'
NUM_TESTS = 1000
random.seed(9001)

class TestPc:
    def __init__(self, last_instr):
        self.pc = 0
        self.last_instr = last_instr

    def update_pc(self, op, acc, jmp_off):
        if op == compiler.OPCODES['JMP'].code or \
           op == compiler.OPCODES['JRO'].code or \
           (op == compiler.OPCODES['JEZ'].code and acc == 0) or \
           (op == compiler.OPCODES['JNZ'].code and acc != 0) or \
           (op == compiler.OPCODES['JGZ'].code and acc > 0) or \
           (op == compiler.OPCODES['JLZ'].code and acc < 0):
            pc_next = self.pc + jmp_off
            self.pc = min(max(0, pc_next), self.last_instr)
        else:
            if self.pc == self.last_instr:
                self.pc = 0
            else:
                self.pc = self.pc + 1


def get_tv_line(op, acc, jmp_off, op_out):
    combined = f'{op:04b}_'
    combined += f'{compiler.truncate_const(acc):011b}_'
    combined += f'{compiler.truncate_const(jmp_off):011b}_'
    combined += f'{op_out:021b}'
    return combined


def main():
    rom_data = []
    with open(TEST_COE) as fd:
            fd.readline()
            fd.readline()
            for line in fd.readlines():
                val = line.replace(',','').replace(';','')
                rom_data.append(int(val, base=16))

    test_pc = TestPc(len(rom_data) - 1)
    with open(OUT_TV, 'w') as fd:
        for i in range(NUM_TESTS):
            op = random.randint(0, len(compiler.OPCODES) - 1)
            acc = random.choice([-compiler.CONST_MAX, -1, 0, 1, compiler.CONST_MAX])
            jmp_off = random.randint(-5, 5)
            test_pc.update_pc(op, acc, jmp_off)
            op_out = rom_data[test_pc.pc]
            fd.write(get_tv_line(op, acc, jmp_off, op_out))
            if i != NUM_TESTS - 1:
                fd.write('\n')

if __name__ == "__main__":
    main()
