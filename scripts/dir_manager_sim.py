from enum import auto, Enum
from typing import Optional, NamedTuple, Dict

NUM_ROWS = 4
NUM_COLS = 4

class NodeState(Enum):
    IDLE = auto()
    FINDING_READ = auto()
    PREPARING_WRITE = auto()
    FINDING_WRITE = auto()

class Target(Enum):
    SELF = auto()
    UP = auto()
    DOWN = auto()
    LEFT = auto()
    RIGHT = auto()
    ANY = auto()

class Cmd(NamedTuple):
    src: Target
    dst: Target
    def __repr__(self):
        return f'({self.src.name} {self.dst.name})'

class TestNode1:
    def __init__(self):
        self.state = NodeState.IDLE
        self.cmd: Cmd = None
        self.neighbors: Dict[Target, Optional[TestNode1]] = None

    def set_neighbors(self, left, right, up, down):
        self.neighbors = {
            Target.LEFT: left,
            Target.RIGHT: right,
            Target.UP: up,
            Target.DOWN: down,
        }

    def clear(self):
        self.state = NodeState.IDLE
        self.cmd = None

    def set_next_cmd(self, cmd:Cmd):
        self.cmd = cmd
        if cmd.src == Target.SELF:
            if cmd.dst == Target.SELF:
                self.state = NodeState.IDLE
                return
            self.state = NodeState.PREPARING_WRITE
            return
        self.state = NodeState.FINDING_READ

    def update(self):
        if self.state == NodeState.PREPARING_WRITE:
           self.state = NodeState.FINDING_WRITE 
        elif self.state == NodeState.FINDING_WRITE:
            target = None
            if self.cmd.dst != Target.ANY:
                if self.neighbors[self.cmd.dst].state == NodeState.FINDING_READ:
                    target = self.neighbors[self.cmd.dst]
            else:
                for neighbor in self.neighbors.values():
                    if neighbor is not None and neighbor.state == NodeState.FINDING_READ:
                        target = neighbor
                        break
            if target is not None:
                target.set_next_cmd(Cmd(Target.SELF, target.cmd.dst))
                self.clear()
        elif self.state == NodeState.IDLE:
            self.clear()


def draw(grid):
    for r, row in enumerate(grid):
        row_str = ''
        for c, node in enumerate(row):
            up = ' '
            if r == 0 or node.neighbors[Target.UP] is None:
                up = 'X'
            elif node.state == NodeState.FINDING_WRITE and (node.cmd.dst == Target.UP or node.cmd.dst == Target.ANY):
                up = '*'
            down = ' '
            if r == NUM_ROWS -1 or node.neighbors[Target.DOWN] is None:
                down = 'X'
            elif node.state == NodeState.FINDING_WRITE and (node.cmd.dst == Target.DOWN or node.cmd.dst == Target.ANY):
                down = '*'
            left = ' '
            if c == 0 or node.neighbors[Target.LEFT] is None:
                left = 'X'
            elif node.state == NodeState.FINDING_WRITE and (node.cmd.dst == Target.LEFT or node.cmd.dst == Target.ANY):
                left = '*'
            right = ' '
            if c == NUM_ROWS -1 or node.neighbors[Target.RIGHT] is None:
                right = 'X'
            elif node.state == NodeState.FINDING_WRITE and (node.cmd.dst == Target.RIGHT or node.cmd.dst == Target.ANY):
                right = '*'
            row_str += f'| L:{left} U:{up} {node.cmd} D:{down} R:{right} |  '
        print(row_str)
        print()

def main():
    grid = []
    
    for _ in range(NUM_ROWS):
        row = []
        for _ in range(NUM_COLS):
            row.append(TestNode1())
        grid.append(row)
    for r, row in enumerate(grid):
        for c, node in enumerate(row):
            up = None
            down = None
            left = None
            right = None
            if r != 0:
                up = grid[r - 1][c]
            if r != NUM_ROWS - 1:
                down = grid[r + 1][c]
            if c != 0:
                left = grid[r][c - 1]
            if c != NUM_COLS - 1:
                right = grid[r][c + 1]
            node.set_neighbors(left, right, up, down)

    for r, row in enumerate(grid):
        for c, node in enumerate(row):
            if c % 2 == 0:
                node.set_next_cmd(Cmd(Target.SELF, Target.ANY))
            else:
                node.set_next_cmd(Cmd(Target.ANY, Target.SELF))
    draw(grid)
    print()
    print()
    print()
    for r, row in enumerate(grid):
        for c, node in enumerate(row):
            node.update()
    draw(grid)
    print()
    print()
    print()
    for r, row in enumerate(grid):
        for c, node in enumerate(row):
            node.update()
    draw(grid)



if __name__ == "__main__":
    main()
