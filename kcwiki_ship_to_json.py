'''Convert KcWiki ship data to json
'''
import re
from pprint import pprint

KCWIKI_SHINKAI_SHIPS = 'original_data/kcwiki_shinkai_ships.txt'
NEDB_EQUIPS = 'db/equips.nedb'

SHIP_ATTRIB_RE_TABLE = {
    'id': re.compile(r'.*编号=(\w*)\|'),
    'class': re.compile(r'.*级别=(\w*)\|'),
    'level': re.compile(r'.*等级=(\w*)\|'),
    'hp': re.compile(r'.*耐久=(\w*)\|'),
    'fire': re.compile(r'.*火力=(\w*)\|'),
    'fire2': re.compile(r'.*火力2=(\w*)\|'),
    'torpedo': re.compile(r'.*雷装=(\w*)\|'),
    'torpedo2': re.compile(r'.*雷装2=(\w*)\|'),
    'aa1': re.compile(r'.*对空=(\w*)\|'),
    'aa2': re.compile(r'.*对空2=(\w*)\|'),
    'armor': re.compile(r'.*装甲=(\w*)\|'),
    'luck': re.compile(r'.*运=(\w*)\|'),
    'range': re.compile(r'.*射程=(\w*)\|'),
    'equip1': re.compile(r'.*装备1=(\w*)\|'),
    'carry1': re.compile(r'.*搭载1=(\w*)\|'),
    'equip2': re.compile(r'.*装备2=(\w*)\|'),
    'carry2': re.compile(r'.*搭载2=(\w*)\|'),
    'equip3': re.compile(r'.*装备3=(\w*)\|'),
    'carry3': re.compile(r'.*搭载3=(\w*)\|'),
    'equip4': re.compile(r'.*装备4=(\w*)\|'),
    'carry4': re.compile(r'.*搭载4=(\w*)\|'),
    'equip5': re.compile(r'.*装备5=(\w*)\|'),
    'carry5': re.compile(r'.*搭载5=(\w*)\|')
}


def orig_wiki_ship_parser(lines):
    '''parser thips data
    '''
    # ships = []
    # pprint(lines)
    pattern = re.compile(r'.+=(.+)\|.+=(.+)}}')
    match = pattern.match(lines[0])
    if match:
        ja_jp, zh_cn = match.group(1, 2)

    headers = []
    # Skip the first line: {{深海栖姬列表
    line_no = 1
    for line in lines[1:]:
        if '{{' in line:
            headers.append(line_no)
        line_no += 1
    headers.append(None)
    for i, j in zip(headers[:-1], headers[1:]):
        ship = {'ja_jp': ja_jp, 'zh_cn': zh_cn}
        single_ship_data = ''.join(lines[i:j]).replace(' ', '').replace('\n', '')
        for key in SHIP_ATTRIB_RE_TABLE:
            match = SHIP_ATTRIB_RE_TABLE[key].match(single_ship_data)
            if match:
                ship[key] = match.group(1) if match.group(1) else '-1'
        pprint(ship)

    return []

def main():
    '''Main process
    '''
    lines = []
    with open(KCWIKI_SHINKAI_SHIPS, 'r', encoding='utf-8') as ships_f:
        lines = ships_f.readlines()

    headers = []
    line_no = 0
    for line in lines:
        if '深海栖姬列表' in line:
            headers.append(line_no)
        line_no += 1
    headers.append(None)

    for i, j in zip(headers[:-1], headers[1:]):
        # print(i, j)
        orig_wiki_ship = lines[i:j]
        to_for_statements = orig_wiki_ship_parser(orig_wiki_ship)

    # start = end


if __name__ == '__main__':
    main()
