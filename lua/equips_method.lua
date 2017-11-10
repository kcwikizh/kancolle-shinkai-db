--- Source code of KcWiki "模块:深海装备函数"
-- Provide lua APIs to get shinkai equip data from "模块:深海装备数据"
-- https://github.com/kcwikizh/kancolle-shinkai-db/tree/develop/lua
-- Please contact us by github issue

-- Wiki text is too long at one line, use table.insert/table.concat to wrap it.
-- \z is supported after lua 5.2, but current version on KcWiki is lua5.1.5.
local p = {}
local equips = {}
if mw then
    -- Kcwiki platform
    equips = require('模块:深海装备数据')
else
    equips = require('equips')
end
local equipDataTable = equips.equipDataTable
local table = {
    concat = table.concat,
    insert = table.insert,
    sort = table.sort
}
local string = {
    format = string.format,
    rep = string.rep
}
local attrDisplaySequence = {
    '火力', '雷装', '爆装', '对空', '装甲', '对潜', '命中', '索敌', '回避'
}
local TYPE_UNKNOW_ID = 99
local equipTypeNameIconTable = {
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
local equipAttrIconTable = {
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


--- Return error massage with span style HTML label
-- @param msg: original message.
-- @return string: message with span style HTML label.
local function errMsg (msg)
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
local function getDataDirectly (equip, args)
    local var = equip

    for i, v in ipairs(args) do
        -- Skip args[1] because it's equip ID.
        if i > 1 then
            if type(var) ~= 'table' then
                return fale, errMsg(string.format('参数个数过多: %s',
                    table.concat(args, '|')))
            end
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
function p.getEquipDataById (frame)
    -- Something strange that:
    -- frame.args can't be table.concat or passed to deep function as parameter
    -- or it will be an empty table, such as: table.concat(frame.args) -> ''
    -- assign it to a local variable 'args', it works.
    local args = {}
    for _, v in ipairs(frame.args) do
        table.insert(args, v)
    end
    local equip = equipDataTable[args[1]]

    if equip == nil then
        return errMsg(string.format('equip ID不存在: %s', args[1]))
    end

    local status, data = getDataDirectly(equip, args)
    if status == false then
        return errMsg(data)
    end

    return data
end
--- Just same with "模块:舰娘装备函数改"
p.getEqDataById = p.getEquipById


--- Generate wiki text of '深海栖舰装备'
-- @return string: HTML text
function p.getEquipsList (frame)
    local output = {}

    table.insert(output, table.concat({
        '<table style="width: 100%; background-color: #f9f9f9; ',
        'border: 1px #aaaaaa solid; border-collapse: collapse;"><tr>'}))
    table.insert(output,
        '<th style="width: 5%; background-color: #e2e2e2;">编号</th>')
    table.insert(output,
        '<th style="width: 5%; background-color: #e2e2e2;">等级</th>')
    table.insert(output,
        '<th style="width: 20%; background-color: #e2e2e2;">名字</th>')
    table.insert(output,
        '<th style="width: 10%; background-color: #e2e2e2;">类型</th>')
    table.insert(output,
        '<th style="width: 40%; background-color: #e2e2e2;">数据</th>')
    table.insert(output,
        '<th style="width: 5%; background-color: #e2e2e2;">射程</th>')
    table.insert(output,
        '<th style="width: 15%; background-color: #e2e2e2;">备注</th>')
    table.insert(output, '</tr>')

    -- Just sort the equip ID
    local equipIdList = {}
    for equipId in pairs(equipDataTable) do
        table.insert(equipIdList, equipId)
    end
    table.sort(equipIdList)

    for _, equipId in ipairs(equipIdList) do
        local equip = equipDataTable[equipId]
        local typeEntry = equipTypeNameIconTable[equip['类别']] or
            equipTypeNameIconTable[equip[TYPE_UNKNOW_ID]]
        if equipTypeNameIconTable[equip['类别']] == nil then
            print(equipId)
            return
        end

        table.insert(output, '<tr>')

        -- equip ID
        table.insert(output, table.concat({
            '<td style="text-align: center; vertical-align: center; ',
            'background-color: #eaeaea; border-style: solid none; ',
            'border-width: 1px;">', equipId, '</td>'}))

        -- rare
        table.insert(output,table.concat({
            '<td style="text-align: center; vertical-align: center; ',
            'background-color: #f2f2f2; border-style: solid none; ',
            'border-width: 1px;">',
            string.rep('☆', equip['稀有度']),
            '</td>'}))
        table.insert(output, table.concat({
            '<td style="background-color: #eaeaea; border-style: solid none; ',
            'border-width: 1px;">'}))

        -- {
        -- name table, include icon, name in ja and zh
        table.insert(output, '<table><tr>')
        -- icon
        table.insert(output, table.concat({
            '<td rowspan="2" style="width: 10%; ',
            'background-color: #cacaca;">',
            equipTypeNameIconTable[equip['类别']].icon or
                equipTypeNameIconTable[TYPE_UNKNOW_ID].icon,
            '</td>'}))
        -- name
        table.insert(output, table.concat({
            '<td style="background-color: #cacaca;">',
            frame:expandTemplate({
                title = "lang", args = {"ja", equip['日文名']}}),
            '</tr>'}))
        table.insert(output, table.concat({
            '<tr><td style="background-color: #eaeaea;">',
            equip['中文名'], '</td></tr>'}))
        table.insert(output, '</table></td>')
        -- end of name table, include icon, name in ja and zh
        -- }

        -- type
        table.insert(output, table.concat({
            '<td style="text-align: center; vertical-align: center; ',
            'background-color: #f2f2f2; border-style: solid none; ',
            'border-width: 1px;">',
            equipTypeNameIconTable[equip['类别']].name or
                equipTypeNameIconTable[TYPE_UNKNOW_ID].name
            '</td>'}))

        -- {
        -- type stat/attribute
        table.insert(output, table.concat({
            '<td style="text-align: left; vertical-align: center; ',
            'background-color: #eaeaea; border-style: solid none; ',
            'border-width: 1px;">'}))
        -- for attrName, attrValue in pairs(equip['属性']) do
        for _, attrName in ipairs(attrDisplaySequence) do
            local attrValue = equip['属性'][attrName]
            if attrValue ~= nil then
                attrValue = tonumber(attrValue)
                if attrValue == nil then
                    attrValue = errMsg('非法属性值: %s: equipid: %d',
                        attrValue, equipId)
                else
                    if attrValue > 0 then
                        attrValue = '+' .. tostring(attrValue)
                    else
                        attrValue = tostring(attrValue)
                    end
                end
                table.insert(output, table.concat({
                    equipAttrIconTable[attrName], attrName, '&nbsp;',
                    attrValue, '&nbsp;'}))
            end
        end
        table.insert(output, '</td>')
        -- end of type stat/attribute
        --}

        -- range/leng
        local range = equip['属性']['射程']
        table.insert(output, table.concat({
            '<td style="text-align: center; vertical-align: center; ',
            'background-color: #f2f2f2; border-style: solid none; ',
            'border-width: 1px;">',
            range or '无',
            '</td>'}))

        -- remarks
        table.insert(output, table.concat({
            '<td style="text-align: left; vertical-align: center; ',
            'background-color: #eaeaea; border-style: solid none; ',
            'border-width: 1px;">',
            equip['备注'] or '',
            '</td>'}))

        table.insert(output, '</tr>')
    end
    table.insert(output, '</table>')

    return(table.concat(output))
end

return p
