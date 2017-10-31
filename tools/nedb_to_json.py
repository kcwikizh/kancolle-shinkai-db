'''Convert nedb to formated json with indent
'''
import json
from argparse import ArgumentParser
from utils import nedb_parser


def do_convert(nedb_datas, fout):
    '''Convert
    '''
    with open(fout, 'w', encoding='utf-8') as json_f:
        json.dump(obj=nedb_datas, fp=json_f, ensure_ascii=False, indent=4)


def main():
    '''Main
    '''
    parser = ArgumentParser(description='convert nedb to json')
    parser.add_argument('-i', '--in', help='nedb file name', dest='fin')
    parser.add_argument('-o', '--out', help='json file name', dest='fout')
    args = parser.parse_args()
    if not all([args.fin, args.fout]):
        print('need parameters')
        return

    nedb_datas = nedb_parser(args.fin)
    do_convert(nedb_datas, args.fout)

if __name__ == '__main__':
    main()
