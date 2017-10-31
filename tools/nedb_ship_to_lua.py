'''Convert ship json to KcWiki lua
'''
from utils import nedb_parser

NEDB_SHIPS = '../db/ships.nedb'
LUA_SHIPS = '../lua/ships.lua'
SHIP_LUA_HEAD = '''local d = {}
------------------------
-- 以下为舰娘数据列表 -- 
------------------------

d.shipDataTb = {
\t'''

SHIP_LUA_TEMPLATE = '''["{id}"] = {{
\t\t["日文名"] = "{name[ja_jp]}",
\t\t["中文名"] = "{name[zh_cn]}",
\t\t["完整日文名"] = "{name[fullname_ja_jp]}",
\t\t["完整中文名"] = "{name[fullname_zh_cn]}",
\t\t["类别"] = "{yomi}",
\t\t["属性"] = {{'''

EQUIP_LUA_TEMPLATE = '''\n\t\t["装备"] = {{
\t\t\t["格数"] = {},
\t\t\t["搭载"] = {{{}}},
\t\t\t["装备"] = {{{}}}
\t\t}}'''

SHIP_LUA_TAIL = '''}

return d'''

SEASON_ID_NAME_TABLE = [
    None,
    '冬',
    '春',
    '夏',
    '秋'
]

SELECTED_RANK_ID_NAME_TABLE = [
    '无',
    '丙',
    '乙',
    '甲'
]


def get_appears_output(ship):
    '''Get the appears info

    OK, Ugly code~~
    VERY UGLY!
    '''
    output = []
    if 'appears' not in ship:
        return ''

    for i in ship['appears']:
        appears_output = []
        map_output = []
        map_output.append('\t\t\t\t\t["限定海域"] = {}'.format(
            'true' if i['map']['is_event'] else 'false'))
        if i['map']['is_event']:
            map_output.append('\n\t\t\t\t\t["年"] = {}'.format(
                i['map']['year']))
            map_output.append('\n\t\t\t\t\t["季节"] = "{}"'.format(
                SEASON_ID_NAME_TABLE[i['map']['season']]))
            map_output.append('\n\t\t\t\t\t["海域"] = "E-{}"'.format(
                i['map']['event_id']))

        map_output.append('\n\t\t\t\t\t["Boss"] = {}'.format(
            'true' if i['map']['is_boss'] else 'false'))

        appears_output.append('\t\t\t\t["map"] = {{\n{}\n\t\t\t\t}}'.format(
            ','.join(map_output)))
        if 'is_final_battle' in i:
            appears_output.append('\n\t\t\t\t["最终战"] = {}'.format(
                'true' if i['is_final_battle'] else 'false'))
        if 'selected_rank' in i:
            appears_output.append('\n\t\t\t\t["选择难度"] = "{}"'.format(
                SELECTED_RANK_ID_NAME_TABLE[i['selected_rank']]))
        output.append('\n\t\t\t{{\n{}\n\t\t\t}}'.format(','.join(appears_output)))

    return '{}\n\t\t}}'.format(','.join(output))


def json_to_lua(ship):
    '''Output the lua code
    '''
    result = SHIP_LUA_TEMPLATE.format(**ship)
    output = []
    stats = ship['stats']

    output.append('\n\t\t\t["耐久"] = {}'.format(stats['taik']))
    output.append('\n\t\t\t["火力"] = {{{}, {}}}'.format(stats['houg'],
                                                       stats['houg2']))
    output.append('\n\t\t\t["雷装"] = {{{}, {}}}'.format(stats['raig'],
                                                       stats['raig2']))
    py_lua_name_table = [
        ('tyku', '对空'),
        ('souk', '装甲'),
        ('luck', '运'),
        ('leng', '射程')
    ]
    for pyname, luaname in py_lua_name_table:
        if pyname in stats:
            output.append('\n\t\t\t["{}"] = {}'.format(luaname,
                                                       stats[pyname]))
    output[-1] += '\n\t\t}'

    output.append(EQUIP_LUA_TEMPLATE.format(
        len(ship['slots']),
        ', '.join(str(i) for i in ship['slots']),
        ', '.join(str(i) for i in ship['equips'])))

    if 'appears' in ship:
        output.append('\n\t\t["出现海域"] = {{{}'.format(get_appears_output(ship)))

    return '{}{}\n\t}}'.format(result, ','.join(output))


def main():
    '''Main process
    '''
    nedb_ships = nedb_parser(NEDB_SHIPS)
    output = []

    for ship_id in nedb_ships:
        ship = nedb_ships[ship_id]
        output.append(json_to_lua(ship))

    with open(LUA_SHIPS, 'w', encoding='utf-8') as lua_f:
        print(SHIP_LUA_HEAD.replace('\t', '    '), end='', file=lua_f)
        print(',\n\t'.join(output).replace('\t', '    '), file=lua_f)
        print(SHIP_LUA_TAIL, file=lua_f)

if __name__ == '__main__':
    main()
