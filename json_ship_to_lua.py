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

SHIP_LUA_TEMPLATE = '''["{kcwiki_id}"] = {{
\t\t["日文名"] = "{name[ja_jp]}",
\t\t["中文名"] = "{name[zh_cn]}",
\t\t["类别"] = {{{class}}},
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
    ship['class'] = ', '.join('"{}"'.format(i) for i in ship['class'])
    result = SHIP_LUA_TEMPLATE.format(**ship)
    attr_lua_list = []
    attr = ship['attr']

    attr_lua_list.append('\n\t\t\t["耐久"] = {}'.format(attr['hp']))
    attr_lua_list.append('\n\t\t\t["火力"] = {{{}, {}}}'.format(attr['fire'],
                                                              attr['fire2']))
    attr_lua_list.append('\n\t\t\t["雷装"] = {{{}, {}}}'.format(attr['torpedo'],
                                                              attr['torpedo2']))
    py_lua_name_table = [
        ('aa', '对空'),
        ('armor', '装甲'),
        ('luck', '运'),
        ('range', '射程')
    ]
    for pyname, luaname in py_lua_name_table:
        if pyname in attr:
            attr_lua_list.append('\n\t\t\t["{}"] = {}'.format(luaname,
                                                              attr[pyname]))
    attr_lua_list[-1] += '\n\t\t}'

    attr_lua_list.append(EQUIP_LUA_TEMPLATE.format(
        ship['carry'],
        ', '.join(str(i) for i in ship['slots']),
        ', '.join(str(i) for i in ship['equips'])))

    return '{}{}\n\t}}'.format(result, ','.join(attr_lua_list))

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
