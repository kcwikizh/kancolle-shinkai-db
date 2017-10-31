'''Convert nedb to formated json with indent
'''
import json
from argparse import ArgumentParser


def main():
    '''Main
    '''
    parser = ArgumentParser(description='convert to nedb')
    parser.add_argument('-i', '--in', help='json file name', dest='fin')
    parser.add_argument('-o', '--out', help='nedb file name', dest='fout')
    args = parser.parse_args()
    if not all([args.fin, args.fout]):
        print('need parameters')
        return

    with open(args.fin, 'r', encoding='utf-8') as json_f:
        objs = json.load(json_f)
        with open(args.fout, 'w', encoding='utf-8') as nedb_f:
            for obj in objs:
                json.dump(obj=objs[obj], fp=nedb_f, ensure_ascii=False)
                nedb_f.write('\n')
                # print(str(objs[obj]).replace("'", '"'), file=nedb_f)

if __name__ == '__main__':
    main()
