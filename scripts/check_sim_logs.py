import sys
import re

START_LINE = 'Command: launch_simulation'



def main(log_file, num_expected):
    logs = []
    cur_log = None
    with open(log_file) as fd:
        for line in fd.readlines():
            if START_LINE in line:
                if cur_log is not None:
                    logs.append(cur_log)
                cur_log = line
            if cur_log is not None:
                cur_log += line
        if cur_log is not None:
            logs.append(cur_log)

    if num_expected != len(logs):
        print(f'ERROR: found {len(logs)} out of {num_expected} results')
        print(f'check {log_file}')
        exit(1)

    complete_re = re.compile(r'tests completed with\s+([0-9]+) errors')
    name_re = re.compile(r"Inspecting design source files for '([a-zA-Z0-9_]+)'")
    

    for log in logs:
        def dump_log():
            print('='*200)
            print(log)
            print('='*200)

        name = None
        errors = None
        for line in log.splitlines():
            if 'ERROR:' in line:
                print('Simulation Error in:')
                dump_log()
                break
            m = complete_re.search(line)
            if m is not None:
                errors = int(m.group(1))
                if errors > 0:
                    print('ERROR: Unit test failed')
                print(f'{name} completed:\t{line}')
            m = name_re.search(line)
            if m is not None:
                name = m.group(1)
        if errors is None:
            print('Results not found in:')
            dump_log()

if __name__ == "__main__":
    main(sys.argv[1], int(sys.argv[2]))
