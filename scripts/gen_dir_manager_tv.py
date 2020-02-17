import compiler
import random

random.seed(9001)

OUT_TV = 'data/dir_manager_tv.mem'

def optional_binary(val, len):
    if val is None:
        return 'x' * len
    else:
        val = compiler.truncate_const(val)
        return f'{val:0{len}b}'


class DirManagerState:

    def __init__(self):
        self.in_src = 0
        self.in_dst = 0
        self.in_left_in_data = 1
        self.in_right_in_data = 2
        self.in_up_in_data = 3
        self.in_down_in_data = 4
        self.in_left_in_valid = 0
        self.in_right_in_valid = 0
        self.in_up_in_valid = 0
        self.in_down_in_valid = 0
        self.in_left_out_ready = 0
        self.in_right_out_ready = 0
        self.in_up_out_ready = 0
        self.in_down_out_ready = 0

        self.out_left_in_ready = 0
        self.out_right_in_ready = 0
        self.out_up_in_ready = 0
        self.out_down_in_ready = 0
        self.out_left_out_data = None
        self.out_right_out_data = None
        self.out_up_out_data = None
        self.out_down_out_data = None
        self.out_left_out_valid = 0
        self.out_right_out_valid = 0
        self.out_up_out_valid = 0
        self.out_down_out_valid = 0
        self.out_clk_en = 1
        self.out_dir_src_data = None
    
    def get_dir_src_data(self):
        if self.out_dir_src_data is None:
            return 999
        return self.out_dir_src_data

    def randomize_dir_in_status(self):
        self.in_left_in_valid = random.randint(0, 1)
        self.in_right_in_valid = random.randint(0, 1)
        self.in_up_in_valid = random.randint(0, 1)
        self.in_down_in_valid = random.randint(0, 1)
        self.in_left_out_ready = random.randint(0, 1)
        self.in_right_out_ready = random.randint(0, 1)
        self.in_up_out_ready = random.randint(0, 1)
        self.in_down_out_ready = random.randint(0, 1)

    def get_tv_line(self):
        combined = f'{self.in_src:03b}_'
        combined += f'{self.in_dst:03b}_'

        combined += f'{self.in_left_in_valid:01b}_'
        combined += f'{self.in_right_in_valid:01b}_'
        combined += f'{self.in_up_in_valid:01b}_'
        combined += f'{self.in_down_in_valid:01b}_'

        combined += f'{self.in_left_out_ready:01b}_'
        combined += f'{self.in_right_out_ready:01b}_'
        combined += f'{self.in_up_out_ready:01b}_'
        combined += f'{self.in_down_out_ready:01b}_'

        combined += f'{self.out_left_in_ready:01b}_'
        combined += f'{self.out_right_in_ready:01b}_'
        combined += f'{self.out_up_in_ready:01b}_'
        combined += f'{self.out_down_in_ready:01b}_'

        combined += optional_binary(self.out_left_out_data, 11) + '_'
        combined += optional_binary(self.out_right_out_data, 11) + '_'
        combined += optional_binary(self.out_up_out_data, 11) + '_'
        combined += optional_binary(self.out_down_out_data, 11) + '_'

        combined += f'{self.out_left_out_valid:01b}_'
        combined += f'{self.out_right_out_valid:01b}_'
        combined += f'{self.out_up_out_valid:01b}_'
        combined += f'{self.out_down_out_valid:01b}_'

        combined += f'{self.out_clk_en:01b}_'
        combined += optional_binary(self.out_dir_src_data, 11)
        return combined

    DIR_SUB = {
            compiler.Target.LEFT: 'left',
            compiler.Target.RIGHT: 'right',
            compiler.Target.UP: 'up',
            compiler.Target.DOWN: 'down'
        }

    def set_target(self, var_format: str, target: compiler.Target, val):
        if target not in DirManagerState.DIR_SUB:
            return
        sub = DirManagerState.DIR_SUB[target]
        setattr(self, var_format.format(sub), val)

    def get_target(self, var_format: str, target: compiler.Target):
        sub = DirManagerState.DIR_SUB[target]
        return getattr(self, var_format.format(sub))

def gen_cmd(src: compiler.Target, dst: compiler.Target, src_wait=0, dst_wait=0):
    lines = []
    state = DirManagerState()
    state.randomize_dir_in_status()
    state.in_src = src.value
    state.in_dst = dst.value
    if src in DirManagerState.DIR_SUB:
        state.set_target('out_{}_in_ready', src, 1)
        for _ in range(src_wait):
            state.out_clk_en = 0
            state.set_target('in_{}_in_valid', src, 0)
            lines.append(state.get_tv_line())
            state.randomize_dir_in_status()
        state.set_target('in_{}_in_valid', src, 1)
        state.out_clk_en = 1
        state.out_dir_src_data = state.get_target('in_{}_in_data', src)
    if dst in DirManagerState.DIR_SUB:
        state.out_clk_en = 0
        if dst_wait == 0:
            state.set_target('in_{}_out_ready', dst, 1)
            lines.append(state.get_tv_line())
            state.set_target('out_{}_out_valid', dst, 1)
            state.set_target('out_{}_out_data', dst, state.get_dir_src_data())
            state.randomize_dir_in_status()
            state.set_target('out_{}_in_ready', src, 0)
        for _ in range(dst_wait):
            lines.append(state.get_tv_line())
            state.set_target('out_{}_out_valid', dst, 1)
            state.set_target('out_{}_out_data', dst, state.get_dir_src_data())
            state.randomize_dir_in_status()
            state.set_target('out_{}_in_ready', src, 0)
            state.set_target('in_{}_out_ready', dst, 0)
        state.set_target('in_{}_out_ready', dst, 1)
        state.out_clk_en = 1
    lines.append(state.get_tv_line())
    return lines

def main():
    lines = []

    lines += gen_cmd(compiler.Target.NIL, compiler.Target.NIL)
    for target in DirManagerState.DIR_SUB.keys():
        for i in range(3):
            lines += gen_cmd(target, compiler.Target.NIL, i)
    for target in DirManagerState.DIR_SUB.keys():
        for i in range(3):
            lines += gen_cmd(compiler.Target.NIL, target, 0, i)
    for target_s in DirManagerState.DIR_SUB.keys():
        for target_d in DirManagerState.DIR_SUB.keys():
            if target_s == target_d:
                continue
            for i in range(3):
                for j in range(3):
                    lines += gen_cmd(target_s, target_d, i, j)
    with open(OUT_TV, 'w') as fd:
        fd.write('\n'.join(lines))

if __name__ == "__main__":
    main()
