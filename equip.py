"""Analysis the start2 data"""
__all__ = ['main']
import json
from collections import OrderedDict
from urllib.request import urlopen

from utils import python_data_to_lua_table

START2_URL = 'https://acc.kcwiki.org/start2'
TIMEOUT_IN_SECOND = 10
START2_JSON = 'data/start2.json'
JA_ZH_JSON = 'data/ja_zh.json'
SINKAI_EQUIP_ID_BASE = 501
EQUIPS_LUA = 'lua/equips2.lua'
EQUIPS_JSON = 'json/equips2.json'
EQUIPS_HR_JSON = 'json/equips2_human_readable.json'


def shinkai_parse_equip(start2):
    """Get shinkai equipments stored by python OrderedDict"""
    equips = [i for i in start2['api_mst_slotitem']
              if i['api_id'] >= SINKAI_EQUIP_ID_BASE]
    equips_dict = OrderedDict({})

    with open(JA_ZH_JSON, 'r', encoding='utf-8') as json_fp:
        ja_zh_table = json.load(json_fp)

    for equip in equips:
        equip_dict = OrderedDict({})
        equip_dict['日文名'] = equip['api_name']
        equip_dict['中文名'] = ja_zh_table.get(equip['api_name'], '')
        if not equip_dict['中文名']:
            print('[{}] {} not found in file {}'.format(equip['api_id'],
                                                        equip['api_name'],
                                                        JA_ZH_JSON))
        # api_type = [大分類, 図鑑表示, カテゴリ, アイコンID, 航空機カテゴリ]
        # equip_dict['类别'] = equip['api_type'][2]
        # equip_dict['图鉴'] = equip['api_type'][3]
        equip_dict['类型'] = equip['api_type']
        equip_dict['稀有度'] = equip['api_rare']
        for lua_variable_name, api_name in [
                ('火力', 'api_houg'),
                ('雷装', 'api_raig'),
                ('爆装', 'api_baku'),
                ('对空', 'api_tyku'),
                ('装甲', 'api_souk'),
                ('对潜', 'api_tais'),
                ('命中', 'api_houm'),
                ('索敌', 'api_saku'),
                ('回避', 'api_houk')]:
            if equip[api_name] > 0:
                equip_dict[lua_variable_name] = equip[api_name]
        equip_dict['射程'] = [
            '无', '短', '中', '长', '超长', '超超长'][equip['api_leng']]

        equips_dict[str(equip['api_id'])] = equip_dict

    return equips_dict


def shinkai_generate_equip_json(start2):
    """Generate shinkai equipment json

    parameter: ensure_ascii works as it in json.dump
    """
    equips = [i for i in start2['api_mst_slotitem']
              if i['api_id'] >= SINKAI_EQUIP_ID_BASE]

    # Add zh-CN name
    with open(JA_ZH_JSON, 'r', encoding='utf-8') as json_fp:
        ja_zh_table = json.load(json_fp)
    for equip in equips:
        equip['api_zh_cn_name'] = ja_zh_table.get(equip['api_name'], '')
        if not equip['api_zh_cn_name']:
            print('[{}] {} not found in file {}'.format(equip['api_id'],
                                                        equip['api_name'],
                                                        JA_ZH_JSON))

    with open(EQUIPS_JSON, 'w', encoding='utf8') as json_fp:
        json.dump(equips, json_fp)
    with open(EQUIPS_HR_JSON, 'w', encoding='utf8') as json_fp:
        json.dump(equips, json_fp, ensure_ascii=False, indent='    ')


def shinkai_generate_equip_lua(start2):
    """Generate KcWiki shinkai equipment Lua table"""
    equips_dict = shinkai_parse_equip(start2)
    with open(EQUIPS_LUA, 'w', encoding='utf8') as lua_fp:
        lua_fp.write('local d = {}\n\n'
                     + 'd.equipDataTable = {\n')
        data, _ = python_data_to_lua_table(equips_dict, level=1)
        lua_fp.write(data)
        lua_fp.write('\n}\n\nreturn d\n')


def utils_load_start2_json(json_file):
    """Load and decode start2.json"""
    print('Download start2 original file to {}'.format(START2_JSON))
    with urlopen(url=START2_URL, timeout=TIMEOUT_IN_SECOND) as url_fp:
        data = url_fp.read().decode('utf8')
    with open(START2_JSON, 'w', encoding='utf8') as json_fp:
        json_fp.write(data)
    with open(json_file, 'r') as file:
        start2 = json.load(file)
    return start2


def main():
    """Main process"""
    start2 = utils_load_start2_json(START2_JSON)

    while True:
        print('== Equip ==')
        print('[1] Generate Shinkai equipment Lua table\n'
              + '[2] Generate Shinkai equipment Json\n'
              + '\n[0] Exit')
        choice = input('> ')
        if choice == '0':
            break
        elif choice == '1':
            print('Generate Shinkai equipments Lua table')
            shinkai_generate_equip_lua(start2)
            print('Done')
        elif choice == '2':
            print('Generate Shinkai equipment Json')
            shinkai_generate_equip_json(start2)
            print('Done')
        else:
            print('Unknown choice: {}'.format(choice))


if __name__ == '__main__':
    main()
