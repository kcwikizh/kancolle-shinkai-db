"""Convert shinkai ship Json to KcWiki Lua """
__all__ = ['main']
import json
from collections import OrderedDict

from utils import python_data_to_lua_table

SHIPS_HR_JSON = 'json/ships_human_readable.json'
SHIPS_LUA = 'lua/ships.lua'


def shinkai_parse_ship(ships):
    """Get shinkai ships stored by python OrderedDict"""
    ships_dict = OrderedDict()

    for ship_id in ships:
        ship = ships[ship_id]
        ship_dict = OrderedDict()
        ship_dict['日文名'] = ship['name']['ja_jp']
        ship_dict['中文名'] = ship['name']['zh_cn']
        ship_dict['完整日文名'] = ship['name']['fullname_ja_jp']
        ship_dict['完整中文名'] = ship['name']['fullname_zh_cn']
        ship_dict['分类'] = ship['yomi']

        attributes_dict = OrderedDict()
        attributes_dict['耐久'] = ship['stats']['taik']
        attributes_dict['火力'] = [
            ship['stats']['houg'],
            ship['stats']['houg2']
            ]
        attributes_dict['雷装'] = [
            ship['stats']['raig'],
            ship['stats']['raig2']
            ]
        attributes_dict['对空'] = ship['stats']['tyku']
        attributes_dict['装甲'] = ship['stats']['souk']
        attributes_dict['运'] = ship['stats']['luck']
        attributes_dict['射程'] = [
            '无', '短', '中', '长', '超长'][ship['stats']['leng']]
        ship_dict['属性'] = attributes_dict

        equip_dict = OrderedDict()
        equip_dict['格数'] = len(ship['slots'])
        equip_dict['搭载'] = ship['slots']
        equip_dict['装备'] = ship['equips']
        ship_dict['装备'] = equip_dict

        appears_list = []
        for appear in ship.get('appears', []):
            appear_dict = OrderedDict()
            appear_dict['map'] = OrderedDict()
            appear_dict['map']['限定海域'] = appear['map']['is_event']
            appear_dict['map']['年'] = appear['map']['year']
            appear_dict['map']['季节'] = [
                None, '冬', '春', '夏', '秋'][appear['map']['season']]
            appear_dict['map']['海域'] = 'E-' + str(appear['map']['event_id'])
            appear_dict['map']['Boss'] = appear['map']['is_boss']
            if 'is_final_battle' in appear:
                appear_dict['最终战'] = appear['is_final_battle']
            if 'selected_rank' in appear:
                appear_dict['选择难度'] = [
                    '无', '丙', '乙', '甲'][appear['selected_rank']]
            appears_list.append(appear_dict)

        if appears_list:
            ship_dict['出现海域'] = appears_list

        ships_dict[ship_id] = ship_dict

    return ships_dict


def shinkai_generate_ship_lua(ships):
    """Generate KcWiki shinkai ship Lua table"""
    ships_dict = shinkai_parse_ship(ships)
    data, _ = python_data_to_lua_table(ships_dict, level=1)
    with open(SHIPS_LUA, 'w', encoding='utf8') as lua_fp:
        lua_fp.write('local d = {}\n\n'
                     + 'd.shipDataTable = {\n')
        lua_fp.write(data)
        lua_fp.write('\n}\n\nreturn d\n')


def load_ships_json(json_file):
    """Load and decode json"""
    print('Load json file: {}'.format(json_file))
    with open(json_file, 'r', encoding='utf8') as file:
        ships = json.load(file)
    return ships


def main():
    """Main process"""
    ships = load_ships_json(SHIPS_HR_JSON)
    shinkai_generate_ship_lua(ships)


if __name__ == '__main__':
    main()
