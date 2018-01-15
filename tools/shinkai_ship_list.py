'''get item of single item of shinkai ship list'''
from utils import nedb_parser

NEDB_SHIPS = '../db/ships.nedb'
NEDB_EQUIPS = '../db/equips.nedb'

MAX_SLOT_NUM = 5

def gen_ship_item(wikiid, nedb_ships, nedb_equips):
    '''Generate one single item'''
    ship = nedb_ships.get(int(wikiid), None)
    if not ship:
        return 'invalid ship id: {}'.format(wikiid)
    ship['stats']['leng'] = ['', '短', '中', '长', '超长'][ship['stats']['leng']]

    output = '{{深海栖姬单条列表\n'
    tmp = '|'.join([
        ' ',
        '编号={id}',
        '名字={name[fullname_zh_cn]}',
        '级别={yomi}',
        '等级=1',
        '耐久={stats[taik]}',
        '火力={stats[houg]}',
        '火力2={stats[houg2]}',
        '雷装={stats[raig]}',
        '雷装2={stats[raig2]}',
        '对空={stats[tyku]}',
        '装甲={stats[souk]}',
        '运={stats[luck]}',
        '射程={stats[leng]}'
    ]).format(**ship)
    output += tmp + '\n'

    tmp = ' '
    for slotid, (equipid, slot) in enumerate(
            zip(ship['equips'], ship['slots']),
            start=1):
        tmp += '|装备{}={}'.format(slotid, nedb_equips[equipid]['name']['zh_cn'])
        if slot > 0:
            tmp += '|搭载{}={}'.format(slotid, slot)

    for i in range(len(ship['slots']) + 1, MAX_SLOT_NUM + 1):
        tmp += '|装备{}='.format(i)

    tmp += '|攻击模式=|备注=}}'
    output += tmp

    return output


def main():
    '''Main process'''
    nedb_ships = nedb_parser(NEDB_SHIPS)
    nedb_equips = nedb_parser(NEDB_EQUIPS)
    while True:
        try:
            print(gen_ship_item(input(), nedb_ships, nedb_equips))
        except EOFError:
            break

if __name__ == '__main__':
    main()
