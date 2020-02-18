import sys
import re
from collections import namedtuple
from enum import Enum
import pickle

# Binary Opcode Format (len in bits):
# [4 op][3 src][11 const][3 dst] = 21 bits
# * op denotes the type of operation
# * src is the source register
# * const is a constant immediate value
# * dst is the destination register
# most op don't need all the fields, only MOV might need them all

OpCode = namedtuple('OpCode', ['code', 'num_args', 'arg_is_label'])

class OpCodeSections:
    def __init__(self, op):
        self.op = op
        self.src = 0
        self.const = 0
        self.dst = 0
    def __repr__(self):
        return f'op:{self.op} src:{self.src} const:{self.const} op:{self.dst}'

OP_BITS = 4
OPCODES = {
    'NOP': OpCode(0, 0, False),

    'MOV': OpCode(1, 2, False),
    'SWP': OpCode(2, 0, False),
    'SAV': OpCode(3, 0, False),

    'ADD': OpCode(4, 1, False),
    'SUB': OpCode(5, 1, False),
    'NEG': OpCode(6, 0, False),

    'JMP': OpCode(7, 1, True),
    'JEZ': OpCode(8, 1, True),
    'JNZ': OpCode(9, 1, True),
    'JGZ': OpCode(10, 1, True),
    'JLZ': OpCode(11, 1, True),
    'JRO': OpCode(12, 1, False),
}

TARGET_BITS = 3
class Target(Enum):
  # NIL also used for src constant
  NIL = 0
  ACC = 1
  UP = 2
  DOWN = 3
  LEFT = 4
  RIGHT = 5
  ANY = 6
  LAST = 7


CONST_MAX = 999
CONST_BITS = 11

def print_error(line, message):
    print(message)
    print('on line:', line)
    exit(1)

def get_register_code(reg_name):
    if reg_name not in [e.name for e in Target]:
        return None
    return Target[reg_name].value


def parse_input(lines):
    original_lines = list(lines)
    labels = {}
    label_re = re.compile(r'([A-Z0-9~`$%^&*()_\-+={}\[\]\|\\;\'"<>,.\?/]+)\s*:')
    output_codes = []
    # Find Labels and strip them and comments
    line_num = 0
    line_offset = 0
    line_map = []
    while(line_num < len(lines)):
        original_line = lines[line_num]
        line = original_line.strip().upper()
        line = line.replace(',',' ')
        # Remove comments
        line = re.sub(r'#.+','', line).strip()
        # Find Labels
        label_search = label_re.match(line)
        if label_search is not None:
            label = label_search.group(1)
            if label in labels.keys():
                print_error(original_line, 'Duplicate label')
            labels[label] = line_num
            line = label_re.sub('', line).strip()
            lines[line_num] = line
        # Remove empty lines
        if re.match(r'^\s*$', line) is not None:
            lines.pop(line_num)
            line_offset += 1
            continue
        line_map.append(line_num + line_offset)
        line_num += 1
    # If last line is label have it jump to first line
    for key, val in labels.items():
        if val >= len(lines):
           labels[key] = 0 
    for line_num in range(len(lines)):
        line = lines[line_num]
        original_line = original_lines[line_map[line_num]]
        parts = line.split()
        if parts[0] not in OPCODES.keys():
            print_error(original_line, 'Invalid opcode')
        opcode_name = parts[0]
        opcode = OPCODES[parts[0]]
        sections = OpCodeSections(opcode.code)
        if len(parts) != opcode.num_args + 1:
            print_error(original_line, f'{opcode_name} expects {opcode.num_args} args')
        if opcode.num_args == 1 and opcode.arg_is_label:
            label = parts[1]
            if label not in labels.keys():
                print_error(original_line, 'Undeclared label')
            sections.src = Target.NIL.value
            sections.const = labels[label] - line_num
        elif opcode.num_args >= 1:
            try: 
                const = int(parts[1])
                if abs(const) > CONST_MAX:
                    print_error(original_line, 'Constant out of range')
                sections.src = Target.NIL.value
                sections.const = const
            except ValueError:
                src = get_register_code(parts[1])
                if src is None:
                    print_error(original_line, 'Invalid source arg')
                sections.src = src
        if opcode.num_args == 2:
            dst = get_register_code(parts[2])
            if dst is None:
                print_error(original_line, 'Invalid destination arg')
            sections.dst = dst
        output_codes.append(sections)
    return output_codes

def bit_mask(nbits):
    return 2**nbits - 1

def truncate_const(const):
    return const & bit_mask(CONST_BITS)

def output_code_to_int(output_code):
    combined = output_code.dst
    offset = TARGET_BITS
    combined |= truncate_const(output_code.const) << offset
    offset += CONST_BITS
    combined |= output_code.src << offset
    offset += TARGET_BITS
    combined |= output_code.op << offset
    return combined

def write_hex_memory_file(hex_file, output_codes):
    lines = []
    for output_code in output_codes:
        combined = output_code_to_int(output_code)
        lines.append(f'{combined:06x}')
    hex_file.write('\n'.join(lines))

def write_hex_coe_file(coe_file, output_codes):
    coe_file.write('memory_initialization_radix = 16;\n')
    coe_file.write('memory_initialization_vector=\n')
    lines = []
    for output_code in output_codes:
        combined = output_code_to_int(output_code)
        lines.append(f'{combined:x}')
    coe_file.write(',\n'.join(lines) + ';')

def write_pickle_file(pickle_file, output_codes):
    pickle.dump( output_codes, pickle_file )

def write_bin_csv_file(csv_file, output_codes):
    lines = []
    for output_code in output_codes:
        combined = f'{output_code.op:04b},'
        combined += f'{output_code.src:03b},'
        const = truncate_const(output_code.const)
        combined += f'{const:011b},'
        combined += f'{output_code.dst:03b}'
        lines.append(combined)
    csv_file.write('\n'.join(lines))

def write_bin_memory_file(bin_file, output_codes):
    lines = []
    for output_code in output_codes:
        combined = output_code_to_int(output_code)
        lines.append(f'{combined:021b}')
    bin_file.write('\n'.join(lines))

def main(asm_file_name, out_file_name, output_type):
    with open(asm_file_name) as fd:
        lines = fd.readlines()
    output_codes = parse_input(lines)
    with open(out_file_name, 'wb') as fd:
        {
            OutType.memh: write_hex_memory_file,
            OutType.memb: write_bin_memory_file,
            OutType.csvb: write_bin_csv_file,
            OutType.coeh: write_hex_coe_file,
            OutType.pick: write_pickle_file
        }[output_type](fd, output_codes)

class OutType(Enum):
    memh = 'memh'
    memb = 'memb'
    csvb = 'csvb'
    coeh = 'coeh'
    pick = 'pick'
    def __str__(self):
        return self.value

if __name__ == "__main__":
    import argparse
    import os.path
    def is_valid_file(parser, arg):
        if not os.path.exists(arg):
            parser.error("The file %s does not exist!" % arg)
        else:
            return arg
    parser = argparse.ArgumentParser(description="Compile TIS asm to binary opcodes")
    parser.add_argument("-t","--type",
                        type=OutType,
                        choices=list(OutType),
                        default=OutType.memb,
                        help="sets output type")
    parser.add_argument("-o","--out_file",
                        default='out.mem',
                        help="sets output file path")
    parser.add_argument("asm_file",
                        type=lambda x: is_valid_file(parser, x),
                        help="Input TIS asm path")
    args = parser.parse_args()
    main(args.asm_file, args.out_file, args.type)
