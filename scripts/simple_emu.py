from enum import Enum, auto
from typing import Dict

from gen_alu_tv import test_saturate

class Operations(Enum):
    NOP = auto()
    MOV = auto()
    SWP = auto()
    SAV = auto()
    ADD = auto()
    SUB = auto()
    NEG = auto()
    JMP = auto()
    JEZ = auto()
    JNZ = auto()
    JGZ = auto()
    JLZ = auto()
    JRO = auto()

MAX_VAL = 999

TARGET_ACC = 1000
TARGET_UP = 1001
TARGET_DOWN = 1002
TARGET_LEFT = 1003
TARGET_RIGHT = 1004

def get_target_match(target):
    return {TARGET_UP: TARGET_DOWN,
            TARGET_DOWN: TARGET_UP,
            TARGET_LEFT: TARGET_RIGHT,
            TARGET_RIGHT: TARGET_LEFT}[target]

class Instruction:
    def __init__(self, op: Operations, src, dst):
        self.op = op
        self.src = src
        self.dst = dst

class WriteStatus(Enum):
    PENDING = auto()
    READY = auto()
    DONE = auto()

class Write:
    def __init__(self, target, value):
        self.target = target
        self.value = value
        self.status = WriteStatus.PENDING

class TisNode:

    def __init__(self, name, rom):
        self.rom = rom
        self.neighbors: Dict[int, TisNode] = {}
        self.write_val: Write = None
        self.acc = 0
        self.bak = 0
        self.pc = 0
        self.name = name

    def _increament_pc(self):
        self.pc += 1
        self.pc %= len(self.rom)

    def _get_target_val(self, target):
        if target <= MAX_VAL:
            return target
        if target == TARGET_ACC:
            return self.acc
        else:
            neighbor = self.neighbors[target]
            neighbor_write = neighbor.write_val
            if neighbor_write is not None and neighbor_write.target == get_target_match(target) and neighbor_write.status == WriteStatus.READY:
                neighbor_write.status = WriteStatus.DONE
                return neighbor_write.value
        return None

    def _mov(self, instr):
        if self.write_val is not None:
            return
        src_val = self._get_target_val(instr.src)
        if src_val is None:
            return
        if instr.dst <= TARGET_ACC:
            if instr.dst == TARGET_ACC:
                self.acc = src_val
            self._increament_pc()
            return
        self.write_val = Write(instr.dst, src_val)

    def _swp(self, instr):
        tmp = self.acc
        self.acc = self.bak
        self.bak = tmp
        self._increament_pc()

    def _sav(self, instr):
        self.bak = self.acc
        self._increament_pc()

    def _add(self, instr):
        src_val = self._get_target_val(instr.src)
        if src_val is None:
            return
        self.acc = test_saturate(src_val + self.acc)
        self._increament_pc()

    def _sub(self, instr):
        src_val = self._get_target_val(instr.src)
        if src_val is None:
            return
        self.acc = test_saturate(self.acc - src_val)
        self._increament_pc()

    def _neg(self, instr):
        self.acc = self.acc * -1
        self._increament_pc()

    def _jmp(self, instr):
        self.pc += instr.src
        self.pc = max(min(self.pc, len(self.rom) - 1), 0)

    def _jez(self, instr):
        if self.acc == 0:
            self._jmp(instr)
        else:
            self._increament_pc()

    def _jnz(self, instr):
        if self.acc != 0:
            self._jmp(instr)
        else:
            self._increament_pc()

    def _jgz(self, instr):
        if self.acc > 0:
            self._jmp(instr)
        else:
            self._increament_pc()

    def _jlz(self, instr):
        if self.acc < 0:
            self._jmp(instr)
        else:
            self._increament_pc()

    def _jro(self, instr):
        src_val = self._get_target_val(instr.src)
        if src_val is None:
            return
        self._jmp(Instruction(Operations.JMP, src_val, 0))

    def step(self):
        instr = self.rom[self.pc]
        {
            Operations.NOP: lambda x: self._increament_pc(),
            Operations.MOV: self._mov,
            Operations.SWP: self._swp,
            Operations.SAV: self._sav,
            Operations.ADD: self._add,
            Operations.SUB: self._sub,
            Operations.NEG: self._neg,
            Operations.JMP: self._jmp,
            Operations.JEZ: self._jez,
            Operations.JNZ: self._jnz,
            Operations.JGZ: self._jgz,
            Operations.JLZ: self._jlz,
            Operations.JRO: self._jro
        }[instr.op](instr)

    def finalize(self):
        if self.write_val is not None:
            if self.write_val.status == WriteStatus.PENDING:
                self.write_val.status = WriteStatus.READY
            elif self.write_val.status == WriteStatus.DONE:
                self.write_val = None
                self._increament_pc()

    def status_str(self):
        return f'PC:{self.pc} ACC:{self.acc}'

class StreamIn(TisNode):
    def __init__(self, name, data):
        TisNode.__init__(self, name, None)
        self.data = data

    def _increament_pc(self):
        self.pc += 1

    def step(self):
        if self.pc == len(self.data):
            return
        out_target = list(self.neighbors.keys())[0]
        data = self.data[self.pc]
        instr = Instruction(Operations.MOV, data, out_target)
        self._mov(instr)

    def status_str(self):
        if self.pc == len(self.data):
            return ''
        return f'D:{self.data[self.pc]}'

class StreamOut(TisNode):
    def __init__(self, name):
        TisNode.__init__(self, name, None)
        self.data = []

    def step(self):
        in_target = list(self.neighbors.keys())[0]
        src_val = self._get_target_val(in_target)
        if src_val is None:
            return
        self.data.append(src_val)

    def status_str(self):
        if len(self.data) == 0:
            return ''
        return f'D:{self.data[-1]}'

IN_DATA = [ i for i in range (10) ]

NODE1_INSTR = [
    Instruction(Operations.MOV, TARGET_UP, TARGET_ACC),
    Instruction(Operations.ADD, 1, TARGET_ACC),
    Instruction(Operations.MOV, TARGET_ACC, TARGET_DOWN)
]

NODE2_INSTR = [
    Instruction(Operations.MOV, TARGET_UP, TARGET_ACC),
    Instruction(Operations.ADD, 10, TARGET_ACC),
    Instruction(Operations.MOV, TARGET_ACC, TARGET_RIGHT)
]

def connect_nodes(nodes):
    for r, row in enumerate(nodes):
        for c, node in enumerate(row):
            if node is None:
                continue
            if r - 1 >= 0 and nodes[r-1][c] is not None:
                node.neighbors[TARGET_UP] = nodes[r-1][c]
            if r + 1 < len(nodes) and nodes[r+1][c] is not None:
                node.neighbors[TARGET_DOWN] = nodes[r+1][c]
            if c - 1 >= 0 and nodes[r][c-1] is not None:
                node.neighbors[TARGET_LEFT] = nodes[r][c-1]
            if c + 1 < len(row) and nodes[r][c+1] is not None:
                node.neighbors[TARGET_RIGHT] = nodes[r][c+1]

def main():
   
    node1 = TisNode('node1', NODE1_INSTR)
    node2 = TisNode('node2', NODE2_INSTR)
    in_stream = StreamIn('in_stream', IN_DATA)
    out_stream = StreamOut('out_stream')

    nodes = [[in_stream, None],
             [node1,     None],
             [node2,     out_stream]]
    connect_nodes(nodes)

    for _ in range(100):
        for row in nodes:
            for node in row:
                if node is not None:
                    node.step()
        for row in nodes:
            for node in row:
                if node is not None:
                    node.finalize()
                    print(node.status_str())

    print(out_stream.data)

if __name__ == "__main__":
    main()