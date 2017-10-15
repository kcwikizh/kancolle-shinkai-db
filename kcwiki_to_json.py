'''Convert KcWiki equipment data to json
'''
KCWIKI_SHINKAI_EQUIPS = 'original_data/kcwiki_shinkai_equips.txt'
NEDB_EQUIPS = 'db/equips.nedb'

ZH_CN_TYPE_ID_TABLE = {
    "小口径主炮": 1,
    "中口径主炮": 2,
    "大口径主炮": 3,
    "副炮": 4,
    "鱼雷": 5,
    "舰上战斗机": 6,
    "舰上爆击机": 7,
    "舰上攻击机": 8,
    "舰上侦察机": 9,
    "水上侦察机": 10,
    "水上爆击机": 11,
    "小型电探": 12,
    "大型电探": 13,
    "声呐": 14,
    "爆雷": 15,
    "追加装甲": 16,
    "机关部强化": 17,
    "对空强化弹": 18,
    "对舰强化弹": 19,
    "VT信管": 20,
    "对空机铳": 21,
    "特殊潜航艇": 22,
    "应急修理要员": 23,
    "上陆用舟艇": 24,
    "旋翼飞机": 25,
    "对潜哨戒机": 26,
    "追加装甲(中型)": 27,
    "追加装甲(大型)": 28,
    "探照灯": 29,
    "简易输送部材": 30,
    "舰艇修理设施": 31,
    "潜水舰鱼雷": 32,
    "照明弹": 33,
    "司令部设施": 34,
    "航空要员": 35,
    "高射装置": 36,
    "对地装备": 37,
    "大口径主炮(II)": 38,
    "水上舰要员": 39,
    "大型声呐": 40,
    "大型飞行艇": 41,
    "大型探照灯": 42,
    "战斗粮食": 43,
    "补给物资": 44,
    "水上战斗机": 45,
    "特型内火艇": 46,
    "陆上攻击机": 47,
    "局地战斗机": 48,
    "<类别未定义>": 57,
    "大型电探(II)": 93,
    "舰上侦察机(II)": 94
}

ZH_CN_RANGE_ID_TABLE = {
    '': 0,
    '短': 1,
    '中': 2,
    '长': 3,
    '超长': 4,
    '超超长': 5 #id:573, 深海潜艇用木屐式机
}


def equip_parser(line):
    '''Parse the each lines from kcwiki
    Return a dictionary contains all infomation'''
    equip = {'name': {}, 'attr': {}}
    key_values = line.split('|')
    equip['id'] = int(key_values[0].split('=')[1])
    equip['kcwiki_id'] = '{:03}'.format(equip['id'])
    equip['rare'] = len(key_values[1].split('=')[1])
    equip['no'] = int(key_values[2].split('=')[1])
    equip['name']['ja_jp'] = key_values[3].split('=')[1]
    equip['name']['zh_cn'] = key_values[4].split('=')[1]
    equip['type'] = ZH_CN_TYPE_ID_TABLE[key_values[5].split('=')[1]]

    for key_value in key_values[6:]:
        try:
            value = key_value.split('=')[1]
        except ValueError:
            print(key_value)
            raise
        if key_value.startswith('火力'):
            equip['attr']['fire'] = int(value)
        elif key_value.startswith('雷装'):
            equip['attr']['torpedo'] = int(value)
        elif key_value.startswith('爆装'):
            equip['attr']['bomb'] = int(value)
        elif key_value.startswith('对空'):
            equip['attr']['aa'] = int(value)
        elif key_value.startswith('装甲'):
            equip['attr']['armor'] = int(value)
        elif key_value.startswith('对潜'):
            equip['attr']['asw'] = int(value)
        elif key_value.startswith('命中'):
            equip['attr']['accuracy'] = int(value)
        elif key_value.startswith('索敌'):
            equip['attr']['los'] = int(value)
        elif key_value.startswith('回避'):
            equip['attr']['evasion'] = int(value)
        elif key_value.startswith('射程'):
            equip['attr']['range'] = ZH_CN_RANGE_ID_TABLE[value]

    return equip


def main():
    '''Main process
    '''
    equips = {}
    with open(KCWIKI_SHINKAI_EQUIPS, 'r', encoding='utf-8') as kcwiki_f:
        for line in kcwiki_f:
            equip = equip_parser(line)
            equips[equip['id']] = equip

    from equip_json_template import TEMPLATE
    with open(NEDB_EQUIPS, 'w', encoding='utf-8') as nedb_f:
        for equip_id in sorted(equips):
            # A bug that:
            # On windows, each line always ends with CRLF('\r\n')
            print(TEMPLATE.format(**equips[equip_id]).replace('\'', '"'), end='\n', file=nedb_f)


if __name__ == '__main__':
    main()
