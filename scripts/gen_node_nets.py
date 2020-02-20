from enum import Enum, auto
from typing import Tuple, List, Optional

class NodeType(Enum):
    IN = auto()
    OUT = auto()
    NODE = auto()

class WireType(Enum):
    IN = auto()
    OUT = auto()
    INOUT = auto()

class Direction(Enum):
    RIGHT = auto()
    DOWN = auto()

class Node:
    def __init__(self, name, type: NodeType):
        self.type = type
        self.name = name

class Wire:
    def __init__(self, node, dir: Direction, other, type: WireType):
        self.type = type
        self.node = node
        self.dir = dir
        self.other = other

def get_dir(dir):
    return {
                Direction.RIGHT: 'right',
                Direction.DOWN: 'down'
            }[dir]

def get_op_dir(dir):
    return {
                Direction.RIGHT: 'left',
                Direction.DOWN: 'up'
            }[dir]

def wire_write(a, b, dir):
    if (a.type == NodeType.IN or a.type == NodeType.OUT) and \
       (b.type == NodeType.IN or b.type == NodeType.OUT):
        return None
    if a.type == NodeType.IN or b.type == NodeType.OUT:
        return Wire(a.name, dir, b.name, WireType.OUT)
    elif a.type == NodeType.OUT or b.type == NodeType.IN:
        return Wire(a.name, dir, b.name, WireType.IN)
    else:
        return Wire(a.name, dir, b.name, WireType.INOUT)



def print_assignments(wire: Wire):
    if wire is None:
        return
    if wire.type != WireType.IN:
        print(f'assign {wire.other}_{get_op_dir(wire.dir)}_in_data = {wire.node}_{get_dir(wire.dir)}_out_data;')
        print(f'assign {wire.other}_{get_op_dir(wire.dir)}_in_valid = {wire.node}_{get_dir(wire.dir)}_out_valid;')
        print(f'assign {wire.node}_{get_dir(wire.dir)}_out_ready = {wire.other}_{get_op_dir(wire.dir)}_in_ready;')
    if wire.type != WireType.OUT:            
        print(f'assign {wire.node}_{get_dir(wire.dir)}_in_data = {wire.other}_{get_op_dir(wire.dir)}_out_data;')
        print(f'assign {wire.node}_{get_dir(wire.dir)}_in_valid = {wire.other}_{get_op_dir(wire.dir)}_out_valid;')
        print(f'assign {wire.other}_{get_op_dir(wire.dir)}_out_ready = {wire.node}_{get_dir(wire.dir)}_in_ready;')


def main():

    in_a_stream = Node('in_a_stream', NodeType.IN)
    in_b_stream = Node('in_b_stream', NodeType.IN)
    out_stream = Node('out_stream', NodeType.OUT)
    node1 = Node('node1', NodeType.NODE)
    node2 = Node('node2', NodeType.NODE)

    nodes:List[List[Optional[Node]]] = [[in_a_stream, in_b_stream],
                                        [node1,       node2],
                                        [None,        out_stream]]

    wires: List[Wire] = []
    for r, row in enumerate(nodes):
        for c, node in enumerate(row):
            if node is None:
                continue
            if r + 1 < len(nodes) and nodes[r+1][c] is not None:
                wires.append(wire_write(node, nodes[r+1][c], Direction.DOWN))
            if c + 1 < len(row) and nodes[r][c+1] is not None:
                wires.append(wire_write(node, nodes[r][c+1], Direction.RIGHT))
  
    
    wire_segments = []
    for row in nodes:
        for node in row:
            if node is None:
                continue
            if node.type == NodeType.IN:
                for wire in wires:
                    if wire is None:
                        continue
                    if wire.node == node.name:
                        print(f'reg signed [10:0] {wire.node}_{get_dir(wire.dir)}_out_data;')
                        print(f'reg {wire.node}_{get_dir(wire.dir)}_out_valid;')
                        print(f'wire {wire.node}_{get_dir(wire.dir)}_out_ready;')
                        print()
                    elif wire.other == node.name:
                        print(f'reg signed [10:0] {wire.other}_{get_dir(wire.dir)}_out_data;')
                        print(f'reg {wire.other}_{get_op_dir(wire.dir)}_out_valid;')
                        print(f'wire {wire.other}_{get_op_dir(wire.dir)}_out_ready;')
                        print()
            elif node.type == NodeType.OUT:
                for wire in wires:
                    if wire is None:
                        continue
                    if wire.node == node.name:
                        print(f'wire signed [10:0] {wire.node}_{get_dir(wire.dir)}_in_data;')
                        print(f'wire {wire.node}_{get_dir(wire.dir)}_in_valid;')
                        print(f'reg {wire.node}_{get_dir(wire.dir)}_in_ready;')
                        print()
                    elif wire.other == node.name:
                        print(f'wire signed [10:0] {wire.other}_{get_op_dir(wire.dir)}_in_data;')
                        print(f'wire {wire.other}_{get_op_dir(wire.dir)}_in_valid;')
                        print(f'reg {wire.other}_{get_op_dir(wire.dir)}_in_ready;')
                        print()
            else:
                for wire in wires:
                    if wire is None:
                        continue
                    if wire.node == node.name:
                        if wire.type != WireType.OUT:
                            wire_segments.append(f'{wire.node}_{get_dir(wire.dir)}_in')
                        if wire.type != WireType.IN:
                            wire_segments.append(f'{wire.node}_{get_dir(wire.dir)}_out')
                    if node.name == wire.other:
                        if wire.type != WireType.OUT:
                            wire_segments.append(f'{wire.other}_{get_op_dir(wire.dir)}_out')
                        if wire.type != WireType.IN:
                            wire_segments.append(f'{wire.other}_{get_op_dir(wire.dir)}_in')

    for wire in wire_segments:
        print(f'wire [10:0] {wire}_data;')
        print(f'wire {wire}_valid;')
        print(f'wire {wire}_ready;')
    print()                
    for wire in wires:
        print_assignments(wire)
    print()
    for row in nodes:
        for node in row:
            if node is None:
                continue
            if node.type == NodeType.NODE:
                for wire in wire_segments:
                    if wire.startswith(node.name + '_'):
                        sub = wire[len(node.name) + 1:]
                        print(f'.{sub}_data({wire}_data),')
                        print(f'.{sub}_valid({wire}_valid),')
                        print(f'.{sub}_ready({wire}_ready),')
                print()
                        
                    
              

if __name__ == "__main__":
    main()