'''Convert equipment json to KcWiki lua
'''
from utils import nedb_parser

NEDB_EQUIPS = 'db/equips.nedb'
LUA_EQUIPS = 'lua/equips.lua'

EQUIP_LUA_HEAD = '''local d = {}
------------------------
-- 以下为装备数据列表 -- 
------------------------

d.equipDataTb = {
\t'''

EQUIP_LUA_TEMPLATE = '''["{kcwiki_id}"] = {{
\t\t["日文名"] = "{name[ja_jp]}",
\t\t["中文名"] = "{name[zh_cn]}",
\t\t["类别"] = {type},
\t\t["图鉴"] =  {no},
\t\t["稀有度"] = {rare},
\t\t["属性"] = {{'''

EQUIP_LUA_TAIL = '''}

return d'''


def json_to_lua(equip):
    '''Output the lua code
    '''
    result = EQUIP_LUA_TEMPLATE.format(**equip)
    attr_lua_list = []
    attr = equip['attr']

    py_lua_name_table = [
        ('fire', '火力'),
        ('torpedo', '雷装'),
        ('bomb', '爆装'),
        ('aa', '对空'),
        ('armor', '装甲'),
        ('asw', '对潜'),
        ('accuracy', '命中'),
        ('los', '索敌'),
        ('evasion', '回避'),
        ('range', '射程')
    ]

    for pyname, luaname in py_lua_name_table:
        if pyname in attr:
            attr_lua_list.append('\n\t\t\t["{}"] = {}'.format(luaname,
                                                              attr[pyname]))

    return '{}{}\n\t\t}}\n\t}}'.format(result, ','.join(attr_lua_list))


def main():
    '''Main process
    '''
    nedb_equips = nedb_parser(NEDB_EQUIPS)
    output = []

    for equip_id in sorted(nedb_equips):
        equip = nedb_equips[equip_id]
        output.append(json_to_lua(equip))

    with open(LUA_EQUIPS, 'w', encoding='utf-8') as lua_f:
        print(EQUIP_LUA_HEAD.replace('\t', '    '), end='', file=lua_f)
        print(',\n\t'.join(output).replace('\t', '    '), file=lua_f)
        print(EQUIP_LUA_TAIL, file=lua_f)


if __name__ == '__main__':
    main()
