'''Convert KcWiki ship data to json
'''
import re
import json
from pprint import pprint

KCWIKI_SHINKAI_SHIPS = 'original_data/kcwiki_shinkai_ships.txt'
NEDB_EQUIPS = 'db/equips.nedb'

RE_SHIP_ID = re.compile(r'.*编号=(.*?)\|')
RE_SHIP_NAMES = re.compile(r'.*中文名=(.*)\|日文名=(.*?)\|')
RE_SHIP_HP = re.compile(r'.*耐久=(.*?)\|')
RE_SHIP_FIRE = re.compile(r'.*火力=(.*?)\|')
RE_SHIP_FIRE2 = re.compile(r'.*火力2=(.*?)\|')
RE_SHIP_TORPEDO = re.compile(r'.*雷装=(.*?)\|')
RE_SHIP_TORPEDO2 = re.compile(r'.*雷装2=(.*?)\|')
RE_SHIP_AA = re.compile(r'.*对空=(.*?)\|')
RE_SHIP_ARMOR = re.compile(r'.*装甲=(.*?)\|')
RE_SHIP_LUCK = re.compile(r'.*运=(.*?)\|')
RE_SHIP_RANGE = re.compile(r'.*射程=(.*?)\|')
RE_SHIP_EQUIP_LIST = [
    re.compile(r'.*装备1=(.*?)\|'),
    re.compile(r'.*装备2=(.*?)\|'),
    re.compile(r'.*装备3=(.*?)\|'),
    re.compile(r'.*装备4=(.*?)\|'),
    re.compile(r'.*装备5=(.*?)\|')
]
MAX_NSLOTS = len(RE_SHIP_EQUIP_LIST)
RE_SHIP_CARRY_LIST = [
    re.compile(r'.*搭载1=(.*?)\|'),
    re.compile(r'.*搭载2=(.*?)\|'),
    re.compile(r'.*搭载3=(.*?)\|'),
    re.compile(r'.*搭载4=(.*?)\|'),
    re.compile(r'.*搭载5=(.*?)\|')
]


SHIP_RANGE_MAPPING_TABLE = {
    '无': -1,
    '超短': 0,
    '短': 1,
    '中': 2,
    '长': 3,
    '超长': 4
}

class MyException(Exception):
    '''My Exception

    I don't want to check the return value of every function when error occurs.
    Raise an exception, just easier to programming.
    '''
    def __init__(self, msg):
        super().__init__(msg)
        self.message = msg

    def __str__(self):
        return self.message


def nedb_parser(nedb):
    '''nedb_parser
    '''
    result = {}
    line_num = 1

    print('Get raw data from {}'.format(nedb))
    with open(nedb, 'r', encoding='utf-8') as nedb_f:
        for line in nedb_f:
            python_object = json.loads(line)
            if not isinstance(python_object, dict):
                raise MyException('Not a python dict, line number {}'.format(line_num))

            line_num += 1
            item_id = python_object['id']
            result[item_id] = python_object

    print('Loaded {} datas from {}'.format(len(result), nedb))
    return result


def kcwiki_ship_get_id(ship, line):
    '''Get the ship ID in line.
    '''
    match = RE_SHIP_ID.match(line)
    if not match:
        raise MyException('No ship ID in line:\n{}'.format(line))
    ship['id'] = match.group(1)


def kcwiki_ship_get_names(ship, line):
    '''Get the japanese & chinese names in line.
    '''
    match = RE_SHIP_NAMES.match(line)
    if not match:
        raise MyException('Get name failed, ship id: {}'.format(ship['id']))
    ship['name'] = {
        'zh_cn': match.group(1),
        'ja_jp': match.group(2)
    }


def kcwiki_ship_get_attributes(ship, line):
    '''Get the basic attributes
    '''
    ship['attr'] = {}
    ship_id = ship['id']
    match = RE_SHIP_HP.match(line)
    if not match:
        raise MyException('Get hp failed, ship id: {}'.format(ship_id))
    ship['attr']['hp'] = int(match.group(1))

    match = RE_SHIP_FIRE.match(line)
    if not match:
        raise MyException('Get fire failed, ship id: {}'.format(ship_id))
    ship['attr']['fire'] = int(match.group(1))

    match = RE_SHIP_FIRE2.match(line)
    if match:
        ship['attr']['fire2'] = int(match.group(1))

    match = RE_SHIP_TORPEDO.match(line)
    if not match:
        raise MyException('Get torpedo failed, ship id: {}'.format(ship_id))
    ship['attr']['torpedo'] = int(match.group(1))

    match = RE_SHIP_TORPEDO2.match(line)
    if match:
        ship['attr']['torpedo2'] = int(match.group(1))

    match = RE_SHIP_AA.match(line)
    if not match:
        raise MyException('Get aa failed, ship id: {}'.format(ship_id))
    ship['attr']['aa'] = int(match.group(1))
    # Notes that AA2 will be ignore now
    # anti-air value of all ships is 0

    match = RE_SHIP_ARMOR.match(line)
    if not match:
        raise MyException('Get armor failed, ship id: {}'.format(ship_id))
    ship['attr']['armor'] = int(match.group(1))

    # Luck and range value are a little special
    # value of most ships is empty, like this:
    #     |运=|射程=|...
    # I regard it as 0
    match = RE_SHIP_LUCK.match(line)
    if not match:
        raise MyException('Get luck failed, ship id: {}'.format(ship_id))
    if match.group(1):
        ship['attr']['luck'] = int(match.group(1))
    else:
        ship['attr']['luck'] = 0

    match = RE_SHIP_RANGE.match(line)
    if not match:
        raise MyException('Get range failed, ship id: {}'.format(ship_id))
    else:
        ship['attr']['range'] = 0


def kcwiki_ship_get_equips(ship, line, equip_name_id_mapping_table):
    '''Parse the equipments
    '''
    equips = []
    slots = []
    for i in range(MAX_NSLOTS):
        match = RE_SHIP_EQUIP_LIST[i].match(line)
        if not match:
            break
        try:
            equips.append(equip_name_id_mapping_table[match.group(1)])
            slots.append(-1)
        except IndexError:
            print(equip_name_id_mapping_table[match.group(1)])
            raise

        match = RE_SHIP_CARRY_LIST[i].match(line)
        if match:
            slots = int(match.group(1))

    ship['equips'] = equips
    ship['slots'] = slots


def kcwiki_ship_line_parser(line, equip_name_id_mapping_table):
    '''Parse each line, return a dictionary, contains ship info
    '''
    ship = {}

    kcwiki_ship_get_id(ship, line)
    kcwiki_ship_get_names(ship, line)
    kcwiki_ship_get_attributes(ship, line)
    kcwiki_ship_get_equips(ship, line, equip_name_id_mapping_table)

    return ship


def main():
    '''Main process
    '''
    nedb_equips = nedb_parser(NEDB_EQUIPS)
    equip_name_id_mapping_table = dict(
        (k['name']['zh_cn'], v) for v, k in nedb_equips.items())
    ships = {}
    with open(KCWIKI_SHINKAI_SHIPS, 'r', encoding='utf-8') as kcwiki_ships_f:
        for line in kcwiki_ships_f:
            ship = kcwiki_ship_line_parser(line.replace('?', ''),
                                           equip_name_id_mapping_table)
            ships[ship['id']] = ship

    # pprint(ships)


if __name__ == '__main__':
    main()
