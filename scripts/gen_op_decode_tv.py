import compiler

OUT_TV = 'data/op_decode_tv.mem'

IN_MUX_SEL_CONST = 0
IN_MUX_SEL_ACC = 1
IN_MUX_SEL_DIR = 2

OUT_MUX_SEL_IN = 0
OUT_MUX_SEL_ALU = 1

INSTR_ALU_ADD = 0
INSTR_ALU_SUB = 1
INSTR_ALU_NEG = 2

INSTR_REG_READ = 0
INSTR_REG_WRITE = 1
INSTR_REG_SWP = 2
INSTR_REG_SAV = 3

def test_opcode_decode(op_code):
    op = op_code >> 17
    src = op_code >> 14 & compiler.bit_mask(3)
    const = op_code >> 3 & compiler.bit_mask(11)
    dst = op_code & compiler.bit_mask(3)

    alu_instr = None
    if op == compiler.OPCODES["ADD"].code:
        alu_instr = INSTR_ALU_ADD
    elif op == compiler.OPCODES["SUB"].code:
        alu_instr = INSTR_ALU_SUB
    elif op == compiler.OPCODES["NEG"].code:
        alu_instr = INSTR_ALU_NEG

    registers_instr = INSTR_REG_READ
    if op == compiler.OPCODES["MOV"].code or alu_instr is not None:
        registers_instr = INSTR_REG_WRITE
    elif op == compiler.OPCODES["SAV"].code:
        registers_instr = INSTR_REG_SAV
    elif op == compiler.OPCODES["SWP"].code:
        registers_instr = INSTR_REG_SWP

    if src == compiler.Target.NIL.value:
        in_mux_sel = IN_MUX_SEL_CONST
    elif src == compiler.Target.ACC.value:
        in_mux_sel = IN_MUX_SEL_ACC
    else:
        in_mux_sel = IN_MUX_SEL_DIR

    if op == compiler.OPCODES["MOV"].code:
        out_mux_sel = OUT_MUX_SEL_IN
    else:
        out_mux_sel = OUT_MUX_SEL_ALU

    return const, op, alu_instr, registers_instr, in_mux_sel, out_mux_sel

def optional_binary(val):
    if val is None:
        return 'xx_'
    else:
        return f'{val:02b}_'

def get_tv_line(op_code, const, pc_instr, alu_instr, registers_instr, in_mux_sel, out_mux_sel):
    combined = f'{op_code:021b}_'
    combined += f'{compiler.truncate_const(const):011b}_'
    combined += f'{pc_instr:04b}_'
    combined += optional_binary(alu_instr)
    combined += optional_binary(registers_instr)
    combined += f'{in_mux_sel:02b}_'
    combined += f'{out_mux_sel:01b}\n'
    return combined


def main():

    TARGETS = [compiler.Target.NIL, compiler.Target.ACC, compiler.Target.ANY]

  
    with open(OUT_TV, 'w') as fd:
        const = 0
        for op in compiler.OPCODES.values():
            for src in TARGETS:
                for dst in TARGETS:
                    sections = compiler.OpCodeSections(op.code)
                    sections.src = src.value
                    sections.const = const
                    sections.dst = dst.value
                    op_code = compiler.output_code_to_int(sections)
                    const, pc_instr, alu_instr, registers_instr, in_mux_sel, out_mux_sel = test_opcode_decode(op_code)
                    fd.write(get_tv_line(op_code, const, pc_instr, alu_instr, registers_instr, in_mux_sel, out_mux_sel))
                    const += 1


if __name__ == "__main__":
    main()
