--- Source code of KcWiki "模块:深海装备函数"
-- Provide lua APIs to get shinkai equip data from "模块:深海装备数据"
-- https://github.com/kcwikizh/kancolle-shinkai-db/tree/develop/lua
-- Please contact us by github issue

-- coding style refers to <<Programming in Lua Third Edition>>
-- but indented is 4 spaces.

-- Wiki text is too long at one line, use table.insert/table.concat to wrap it.
-- \z is supported after lua 5.2, but current version on KcWiki is lua5.1.5.

-- If you are pasting source code to 模块:深海装备函数
-- You must uncomment this block
-- local equips = require('模块:深海装备数据')
-- If you are pasting source code to 模块:深海装备函数
-- You must comment this line
local equips = require('equips')
local table = {
    concat = table.concat,
    insert = table.insert,
    sort = table.sort
}
local string = {
    format = string.format,
    rep = string.rep
}
local attr_display_sequence = {
    '火力', '雷装', '爆装', '对空', '装甲', '对潜', '命中', '索敌', '回避'
}
local TYPE_UNKNOW_ID = 99
local equip_type_name_icon_table = {
	[1] = {
        name = '小口径主炮',
        icon = '[[文件:IcoMainLight.png|35px|小口径主炮]]'
    },
    [2] = {
        name = '中口径主炮',
        icon = '[[文件:IcoMainMedium.png|35px|中口径主炮]]'
    },
    [3] = {
        name = '大口径主炮',
        icon = '[[文件:IcoMainHeavy.png|35px|大口径主炮]]'
    },
    [4] = {
        name =  '副炮',
        icon = '[[文件:IcoSub.png|35px|副炮]]'
    },
    [5] = {
        name = '鱼雷',
        icon = '[[文件:IcoTorpedoEquip.png|35px|鱼雷]]'
    },
    [6] = {
        name = '舰上战斗机',
        icon = '[[文件:IcoCarrierFighter.png|35px|舰战机]]'
    },
    [7] = {
        name = '舰上爆击机',
        icon = '[[文件:IcoCarrierBomber.png|35px|舰爆机]]'
    },
    [8] = {
        name = '舰上攻击机',
        icon = '[[文件:IcoCarrierTorpedo.png|35px|舰攻机]]',
    },
    [9] = {
        name = '舰上侦察机',
        icon = '[[文件:IcoCarrierRecon.png|35px|舰侦机]]'
    },
    [10] = {
        name = '水上侦察机',
        icon = '[[文件:IcoSeaplane.png|35px|水侦机]]'
    },
    [11] = {
        name = '水上爆击机',
        icon = '[[文件:IcoSeaplane.png|35px|水侦机]]'
    },
    [12] = {
        name = '小型电探',
        icon = '[[文件:IcoRadar.png|35px|电探]]'
    },
    [13] = {
        name = '大型电探',
        icon = '[[文件:IcoRadar.png|35px|电探]]'
    },
    [14] = {
        name = '声呐',
        icon = '[[文件:IcoASWSonar.png|35px|声呐]]'
    },
    [15] = {
        name = '爆雷',
        icon = '[[文件:IcoDepth.png|35px|爆雷]]'
    },
    [17] = {
        name = '机关部强化',
        icon = '[[文件:IcoEngine.png|35px|机关]]'
    },
    [18] = {
        name = '対空散弾',
        icon = '[[文件:IcoAAShell.png|35px|对空弹]]'
    },
    [19] = {
        name = '对舰强化弹',
        icon = '[[文件:IcoShell.png|35px|对舰弹]]'
    },
    [21] = {
        name = '对空机铳',
        icon = '[[文件:IcoAAGun.png|35px|机枪]]'
    },
    [22] = {
        name = '特殊潜航艇',
        icon = '[[文件:IcoTorpedoEquip.png|35px|鱼雷]]'
    },
    [29] = {
        name = '探照灯',
        icon = '[[文件:IcoSearchlight.png|35px|探照灯]]'
    },
    [41] = {
        name = '大型飞行艇',
        icon = '[[文件:IcoRecon.png|35px|水上飞行艇]]'
    },
    [TYPE_UNKNOW_ID] = {
        name = '未知',
        icon = '[[文件:IcoNone.png|35px|暂无]]'
    }
}
local equip_attr_icon_table = {
	["火力"] = "[[文件:IcoAtk.png|20px|火力]]",
	["雷装"] = "[[文件:IcoTorpedo.png|20px|雷装]]",
	["爆装"] = "[[文件:IcoDive.png|20px|爆装]]",
	["对空"] = "[[文件:IcoAA.png|20px|对空]]",
	["装甲"] = "[[文件:IcoArmor.png|20px|装甲]]",
	["对潜"] = "[[文件:IcoASW.png|20px|对潜]]",
	["命中"] = "[[文件:IcoHit.png|20px|命中]]",
	["索敌"] = "[[文件:IcoLOS.png|20px|索敌]]",
	["回避"] = "[[文件:IcoEvasion.png|20px|回避]]",
}
local equip_data_table = equips.equip_data_table
local p = {}


--- Return error massage with span style HTML label
-- @param msg: original message.
-- @return string: message with span style HTML label.
local function err_msg (msg)
    if msg == nil then
        retrurn ''
    end
    return string.format('<span style="color:#ee8080">%s</span>', msg)
end


--- Get the data directly, specified by args
-- @param equip: lua table of this equip
-- @param args: frame.args, all parameters by invoke {{#invoke:}} of wiki.
-- @return (bool, string) : true and the data that user want to get,
-- or false followed by an error message.
local function get_data_directly (equip, args)
    local var = equip

    for i, v in ipairs(args) do
        -- Skip args[1] because it's equip ID.
        if i > 1 then
            var = var[v]
            if var == nil then
                return false, string.format('索引越界: %s',
                    table.concat(args, '|'))
            end
        end
    end

    if type(var) == 'table' then
        return false, string.format('参数个数过少: %s',
            table.concat(args, '|'))
    end

    return true, tostring(var)
end

--- Get the equip data by equip id (api_start2)
-- @param frame: all parameters by invoke {{#invoke:}} of wiki.
-- @return string: the formated data, or error messages.
function p.get_equip_by_id (frame)
    local equip = equip_data_table[frame.args[1]]

    if equip == nil then
        return err_msg(string.format('equip ID不存在: %s', frame.args[1]))
    end

    local status, data = get_data_directly(equip, frame.args)
    if status == false then
        return err_msg(data)
    end

    return data
end
--- Just same with "模块:舰娘装备函数改"
p.getEqDataById = p.get_equip_by_id


--- Generate wiki text of '深海栖舰装备'
-- @return string: Wiki test
function p.get_equips_list_wiki ()
    local my_wikitext = {}

    table.insert(my_wikitext, table.concat({
        '<table style="width: 100%; background-color: #f9f9f9; ',
        'border: 1px #aaaaaa solid; border-collapse: collapse;"><tr>'}))
    table.insert(my_wikitext,
        '<th style="width: 5%; background-color: #e2e2e2;">编号</th>')
    table.insert(my_wikitext,
        '<th style="width: 5%; background-color: #e2e2e2;">等级</th>')
    table.insert(my_wikitext,
        '<th style="width: 15%; background-color: #e2e2e2;">名字</th>')
    table.insert(my_wikitext,
        '<th style="width: 10%; background-color: #e2e2e2;">类型</th>')
    table.insert(my_wikitext,
        '<th style="width: 20%; background-color: #e2e2e2;">数据</th>')
    table.insert(my_wikitext,
        '<th style="width: 5%; background-color: #e2e2e2;">射程</th>')
    table.insert(my_wikitext, '</tr>')

    -- Just sort the equip ID
    local equip_id_list = {}
    for equip_id in pairs(equip_data_table) do
        table.insert(equip_id_list, equip_id)
    end
    table.sort(equip_id_list)

    for _, equip_id in ipairs(equip_id_list) do
        local equip = equip_data_table[equip_id]
        local type_entry = equip_type_name_icon_table[equip['类别']] or
            equip_type_name_icon_table[equip[TYPE_UNKNOW_ID]]
        if equip_type_name_icon_table[equip['类别']] == nil then
            print(equip_id)
            return
        end

        table.insert(my_wikitext, '<tr>')

        -- equip ID
        table.insert(my_wikitext, table.concat({
            '<td style="text-align: center; vertical-align: center; ',
            'background-color: #eaeaea; border-style: solid none; ',
            'border-width: 1px;">', equip_id, '</td>'}))

        -- rare
        table.insert(my_wikitext,table.concat({
            '<td style="text-align: center; vertical-align: center; ',
            'background-color: #f2f2f2; border-style: solid none; ',
            'border-width: 1px;">',
            string.rep('☆', equip['稀有度']),
            '</td>'}))
        table.insert(my_wikitext, table.concat({
            '<td style="background-color: #eaeaea; border-style: solid none; ',
            'border-width: 1px;">'}))

        -- {
        -- name table, include icon, name in ja and zh
        table.insert(my_wikitext, '<table><tr>')
        -- icon
        table.insert(my_wikitext, table.concat({
            '<td rowspan="2" style="width: 10%; ',
            'background-color: #cacaca;">',
            equip_type_name_icon_table[equip['类别']].icon or
                equip_type_name_icon_table[TYPE_UNKNOW_ID].icon,
            '</td>'}))
        -- name
        table.insert(my_wikitext, table.concat({
            '<td lang="ja" xml:lang="ja" style="background-color: #cacaca;">',
            equip['日文名'], '</tr>'}))
        table.insert(my_wikitext, table.concat({
            '<tr><td style="background-color: #eaeaea;">',
            equip['中文名'], '</td></tr>'}))
        table.insert(my_wikitext, '</table></td>')
        -- end of name table, include icon, name in ja and zh
        -- }

        -- type
        table.insert(my_wikitext, table.concat({
            '<td style="text-align: center; vertical-align: center; ',
            'background-color: #f2f2f2; border-style: solid none; ',
            'border-width: 1px;">',
            equip_type_name_icon_table[equip['类别']].name or
                equip_type_name_icon_table[TYPE_UNKNOW_ID].name
            '</td>'}))

        -- {
        -- type stat/attribute
        table.insert(my_wikitext, table.concat({
            '<td style="text-align: left; vertical-align: center; ',
            'background-color: #eaeaea; border-style: solid none; ',
            'border-width: 1px;">'}))
        -- for attr_name, attr_value in pairs(equip['属性']) do
        for _, attr_name in ipairs(attr_display_sequence) do
            local attr_value = equip['属性'][attr_name]
            if attr_value ~= nil then
                attr_value = tonumber(attr_value)
                if attr_value == nil then
                    attr_value = err_msg('非法属性值: %s: equipid: %d',
                        attr_value, equip_id)
                else
                    if attr_value > 0 then
                        attr_value = '+' .. tostring(attr_value)
                    else
                        attr_value = tostring(attr_value)
                    end
                end
                table.insert(my_wikitext, table.concat({
                    equip_attr_icon_table[attr_name], attr_name, '&nbsp;',
                    attr_value, '&nbsp;'}))
            end
        end
        table.insert(my_wikitext, '</td>')
        -- end of type stat/attribute
        --}

        -- range/leng
        local range = equip['属性']['射程']
        table.insert(my_wikitext, table.concat({
            '<td style="text-align: center; vertical-align: center; ',
            'background-color: #f2f2f2; border-style: solid none; ',
            'border-width: 1px;">',
            range or '无',
            '</td>'}))

        table.insert(my_wikitext, '</tr>')
    end
    table.insert(my_wikitext, '</table>')

    return(table.concat(my_wikitext))
end
p.equipDataList = p.get_equips_list_wiki


return p
