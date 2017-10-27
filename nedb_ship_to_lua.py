'''Convert ship json to KcWiki lua
'''
from utils import nedb_parser

NEDB_SHIPS = 'db/ships.nedb'
LUA_SHIPS = 'lua/ships.lua'
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

def json_to_lua(ship):
    '''Output the lua code
    '''
    # original ship['class'] is a list contains strings:
    # ['elite', 'flagship']
    #
    # we need a pure string:
    # '"elite", "flagship"'
    # ship['class'] = ', '.join('"{}"'.format(i) for i in ship['class'])
    result = SHIP_LUA_TEMPLATE.format(**ship)
    stats_lua_list = []
    stats = ship['stats']

    stats_lua_list.append('\n\t\t\t["耐久"] = {}'.format(stats['taik']))
    stats_lua_list.append('\n\t\t\t["火力"] = {{{}, {}}}'.format(stats['houg'],
                                                               stats['houg2']))
    stats_lua_list.append('\n\t\t\t["雷装"] = {{{}, {}}}'.format(stats['raig'],
                                                               stats['raig2']))
    py_lua_name_table = [
        ('tyku', '对空'),
        ('souk', '装甲'),
        ('luck', '运'),
        ('leng', '射程')
    ]
    for pyname, luaname in py_lua_name_table:
        if pyname in stats:
            stats_lua_list.append('\n\t\t\t["{}"] = {}'.format(luaname,
                                                              stats[pyname]))
    stats_lua_list[-1] += '\n\t\t}'

    stats_lua_list.append(EQUIP_LUA_TEMPLATE.format(
        len(ship['slots']),
        ', '.join(str(i) for i in ship['slots']),
        ', '.join(str(i) for i in ship['equips'])))

    return '{}{}\n\t}}'.format(result, ','.join(stats_lua_list))

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
