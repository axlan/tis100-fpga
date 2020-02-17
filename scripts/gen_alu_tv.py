import compiler

OUT_TV = 'data/alu_tv.mem'
NUM_TESTS = 1000

OP_ADD = 0
OP_SUB = 1
OP_NEG = 2


def test_saturate(val):
    return min(max(-compiler.CONST_MAX, val), compiler.CONST_MAX)

def test_alu(instr, acc, src):
    res = {
        OP_ADD: acc + src,
        OP_SUB: acc - src,
        OP_NEG: -acc
    }[instr]
    return test_saturate(res)

def get_tv_line(instr, acc, src, out):
    combined = f'{instr:02b}_'
    combined += f'{compiler.truncate_const(acc):011b}_'
    combined += f'{compiler.truncate_const(src):011b}_'
    combined += f'{compiler.truncate_const(out):011b}'
    return combined


def main():

    STIMULI = [
        [OP_ADD, 1, 1],
        [OP_SUB, 1, 1],
        [OP_NEG, 1, 1],
        [OP_ADD, compiler.CONST_MAX, compiler.CONST_MAX],
        [OP_ADD, -compiler.CONST_MAX, -compiler.CONST_MAX],
        [OP_SUB, -900, 100]
    ]

    with open(OUT_TV, 'w') as fd:
        for stimulus in STIMULI:
            instr, acc, src = tuple(stimulus)
            out = test_alu(instr, acc, src)
            fd.write(get_tv_line(instr, acc, src, out))
            if stimulus != STIMULI[-1]:
                fd.write('\n')

if __name__ == "__main__":
    main()
