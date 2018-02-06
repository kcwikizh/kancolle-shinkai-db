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
    equips = require('equips2')
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
local TYPE_UNKNOW_ID = -1
local equipCategoryTable = {
    [1] = '小口径主炮',
    [2] = '中口径主炮',
    [3] = '大口径主炮',
    [4] = '副炮',
    [5] = '鱼雷',
    [6] = '舰上战斗机',
    [7] = '舰上爆击机',
    [8] = '舰上攻击机',
    [9] = '舰上侦察机',
    [10] = '水上侦察机',
    [11] = '水上爆击机',
    [12] = '小型电探',
    [13] = '大型电探',
    [14] = '声呐',
    [15] = '爆雷',
    [17] = '机关部强化',
    [18] = '对空散弾',
    [19] = '对舰强化弹',
    [21] = '对空机铳',
    [22] = '特殊潜航艇',
    [29] = '探照灯',
    [41] = '大型飞行艇',
    [TYPE_UNKNOW_ID] = '未知',
}
local equipIconTable = {
    [1] = "[[文件:IcoMainLight.png|35px|小口径主炮]]",
    [2] = "[[文件:IcoMainMedium.png|35px|中口径主炮]]",
    [3] = "[[文件:IcoMainHeavy.png|35px|大口径主炮]]",
    [4] = "[[文件:IcoSub.png|35px|副炮]]",
    [5] = "[[文件:IcoTorpedoEquip.png|35px|鱼雷]]",
    [6] = "[[文件:IcoCarrierFighter.png|35px|舰战机]]",
    [7] = "[[文件:IcoCarrierBomber.png|35px|舰爆机]]",
    [8] = "[[文件:IcoCarrierTorpedo.png|35px|舰攻机]]",
    [9] = "[[文件:IcoCarrierRecon.png|35px|舰侦机]]",
    [10] = "[[文件:IcoSeaplane.png|35px|水侦机]]",
    [11] = "[[文件:IcoRadar.png|35px|电探]]",
    [12] = "[[文件:IcoAAShell.png|35px|对空弹]]",
    [13] = "[[文件:IcoShell.png|35px|对舰弹]]",
    [14] = "[[文件:IcoDamecon.png|35px|应急修理要员]]",
    [15] = "[[文件:IcoAAGun.png|35px|机枪]]",
    [16] = "[[文件:IcoMainAA.png|35px|对空主炮]]",
    [17] = "[[文件:IcoDepth.png|35px|爆雷]]",
    [18] = "[[文件:IcoASWSonar.png|35px|声呐]]",
    [19] = "[[文件:IcoEngine.png|35px|机关]]",
    [20] = "[[文件:IcoLanding.png|35px|上陆用舟艇]]",
    [21] = "[[文件:IcoAutogyro.png|35px|旋翼机]]",
    [22] = "[[文件:IcoAirAS.png|35px|对潜哨戒机]]",
    [23] = "[[文件:IcoBulge.png|35px|增设装甲]]",
    [24] = "[[文件:IcoSearchlight.png|35px|探照灯]]",
    [25] = "[[文件:IcoSupply.png|35px|输送部材]]",
    [26] = "[[文件:IcoFacility.png|35px|舰艇修理设施]]",
    [27] = "[[文件:IcoFlare.png|35px|照明弹]]",
    [28] = "[[文件:IcoFleetCom.png|35px|舰队司令部设施]]",
    [29] = "[[文件:IcoAviation.png|35px|航空要员]]",
    [30] = "[[文件:IcoAAFD.png|35px|高射装置]]",
    [31] = "[[文件:IcoAG.png|35px|对地弹]]",
    [32] = "[[文件:IcoPersonnel.png|35px|水上舰要员]]",
    [33] = "[[文件:IcoRecon.png|35px|水上飞行艇]]",
    [34] = "[[文件:IcoRations.png|35px|战斗粮食]]",
    [35] = "[[文件:IcoSupplies.png|35px|洋上补给]]",
    [36] = "[[文件:IcoLandingCraft.png|35px|特型内火艇]]",
    [37] = "[[文件:IcoLand-basedAttackAircraft.png|35px|陆上攻击机]]",
    [38] = "[[文件:IcoInterceptorFighter.png|35px|局地战斗机]]",
    [39] = "[[文件:Ico39JetPoweredFighterBomber.png|35px|喷气式战斗轰炸机]]",
    [40] = "[[文件:Ico40JetPoweredFighterBomber.png|35px|喷气式战斗轰炸机]]",
    [41] = "[[文件:Icon41TransportationMaterial.png|35px|输送部材]]",
    [42] = "[[文件:Icon42SubmarineRadar.png|35px|潜水艇装备]]",
    [43] = "[[文件:IconSeaplaneFighter.png|35px|水战机]]",
    [44] = "[[文件:InterceptorFighterIcon2.png|35px|陆军战斗机]]",
    [45] = "[[文件:IconNightFighter.png|37px|夜间舰战机]]",
    [46] = "[[文件:IconNightTorpedo.png|42px|夜间舰攻机]]",
    [47] = "[[文件:IconAntiSubmarine.png|36px|对潜哨戒机]]",
    [TYPE_UNKNOW_ID] = '[[文件:IcoNone.png|35px|暂无]]',
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
local CATEGORY = 3
local ICON_ID = 4
local spicialCaseHandlers = {
    ['579'] = function (equip)
        -- Fix icon id of 深海14英寸海峡连装炮
        --
        -- original value in start2 is: 1 小口径主炮
        -- fix it to: 3 大口径主炮
        equip['类型'][ICON_ID] = 3
    end
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
-- @return string: the data that user want to get.
local function getDataDirectly (equip, args)
    local var = equip

    for i, v in ipairs(args) do
        -- Skip args[1] because it's equip ID.
        if i > 1 then
            if type(var) ~= 'table' then
                error(string.format('参数个数过多: %s', table.concat(args, '|')))
            end
            var = var[v]
            if var == nil then
                error(string.format('索引越界: %s', table.concat(args, '|')))
            end
        end
    end

    if type(var) == 'table' then
        error(string.format('参数个数过少: %s', table.concat(args, '|')))
    end

    return tostring(var)
end


--- Get the equip data by equip id (api_start2)
-- @param frame: all parameters by invoke {{#invoke:}} of wiki.
-- @return string: the formated data.
function p.getEquipDataById (frame)
    -- Something strange that:
    -- frame.args can't be table.concat or passed to deep function as parameter
    -- or it will be an empty table, such as: table.concat(frame.args) -> ''
    -- assign it to a local variable 'args', it works.
    local args = {}
    for _, v in ipairs(frame.args) do
        table.insert(args, v)
    end
    local equipId = args[1]
    local equip = equipDataTable[equipId]

    if equip == nil then
        return errMsg(string.format('equip ID不存在: %s', equipId))
    end

    -- api_type = [大分類, 図鑑表示, カテゴリ, アイコンID, 航空機カテゴリ]
    -- 类型五元组 = [大分类, 图鉴表示, 类型, 图鉴ID, 航空器类型]
    -- 但实际使用过程中，深海装备的小图标使用“图鉴ID”而非“图鉴表示”
    if args[2] == '类别' then
        return equip['类型'][CATEGORY]
    elseif args[2] == '图鉴' then
        -- hanlder the special case firstly
        local handler = spicialCaseHandlers[equipId]
        if handler then
            handler(equip)
        end
        return equip['类型'][ICON_ID]
    end

    local status, data = pcall(getDataDirectly, equip, args)
    if status == false then
        return errMsg(data)
    end

    return data
end
--- Just same with "模块:舰娘装备函数改"
p.getEqDataById = p.getEquipById


--- Generate wiki text of '深海栖舰装备'
-- @return string: HTML text
function p.getEquipsListHtml (frame)
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

        -- hanlder the special case firstly
        local handler = spicialCaseHandlers[equipId]
        if handler then
            handler(equip)
        end

        local equipCategory = equipCategoryTable[equip['类型'][CATEGORY]] or
                equipCategoryTable[TYPE_UNKNOW_ID]
        local equipIcon = equipIconTable[equip['类型'][ICON_ID]] or
                equipIconTable[TYPE_UNKNOW_ID]

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
            equipIcon,
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
            equipCategory,
            '</td>'}))

        -- {
        -- type stat/attribute
        table.insert(output, table.concat({
            '<td style="text-align: left; vertical-align: center; ',
            'background-color: #eaeaea; border-style: solid none; ',
            'border-width: 1px;">'}))
        -- for attrName, attrValue in pairs(equip['属性']) do
        for _, attrName in ipairs(attrDisplaySequence) do
            local attrValue = equip[attrName]
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
        local range = equip['射程']
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

    return table.concat(output)
end

--- Generate wiki text of '深海栖舰装备'
-- @return string: media wiki text
function p.getEquipsListMediawiki (frame)
    local output = {}

    -- table header
    local header = {}
    table.insert(header, table.concat({
        '{| style="width: 100%; background-color: #f9f9f9; ',
        'border: 1px #aaaaaa solid; border-collapse: collapse;"'}))
    table.insert(header,
        '! style="width: 5%; background-color: #e2e2e2;" | 编号')
    table.insert(header,
        '! style="width: 5%; background-color: #e2e2e2;" | 等级')
    table.insert(header,
        '! style="width: 20%; background-color: #e2e2e2;" | 名字')
    table.insert(header,
        '! style="width: 10%; background-color: #e2e2e2;" | 类型')
    table.insert(header,
        '! style="width: 40%; background-color: #e2e2e2;" | 数据')
    table.insert(header,
        '! style="width: 5%; background-color: #e2e2e2;" | 射程')
    table.insert(header,
        '! style="width: 5%; background-color: #e2e2e2;" | 备注')
    table.insert(output, table.concat(header, '\n'))

    -- Just sort the equip ID
    local equipIdList = {}
    for equipId in pairs(equipDataTable) do
        table.insert(equipIdList, equipId)
    end
    table.sort(equipIdList)

    for _, equipId in ipairs(equipIdList) do
        local equip = equipDataTable[equipId]

        -- hanlder the special case firstly
        local handler = spicialCaseHandlers[equipId]
        if handler then
            handler(equip)
        end

        local equipCategory = equipCategoryTable[equip['类型'][CATEGORY]] or
                equipCategoryTable[TYPE_UNKNOW_ID]
        local equipIcon = equipIconTable[equip['类型'][ICON_ID]] or
                equipIconTable[TYPE_UNKNOW_ID]

        local row = {} -- single row of each equipment
        -- equip ID
        table.insert(row, table.concat({
            '| style="text-align: center; vertical-align: center; ',
            'background-color: #eaeaea; border-style: solid none; ',
            'border-width: 1px;" | ', equipId}))

        -- rare
        table.insert(row, table.concat({
            '| style="text-align: center; vertical-align: center; ',
            'background-color: #f2f2f2; border-style: solid none; ',
            'border-width: 1px;" | ', string.rep('☆', equip['稀有度'])}))

        -- {
        -- name table, include icon, name in ja and zh
        table.insert(row, table.concat({
            '| style="background-color: #eaeaea; border-style: solid none; ',
            'border-width: 1px;" |'}))
        table.insert(row, '  {|')
        -- icon
        table.insert(row, table.concat({
            '   | rowspan="2" style="width: 10%;',
            'background-color: #cacaca;" | ',
            equipIcon}))
        -- name
        table.insert(row, table.concat({
            '   | style="background-color: #cacaca;" | ',
            frame:expandTemplate({
                title = "lang", args = {"ja", equip['日文名']}})
            }))
        table.insert(row, '   |-')
        table.insert(row, table.concat({
            '   | style="background-color: #eaeaea;" | ', equip['中文名']}))
        table.insert(row, '  |}')
        -- end of name table, include icon, name in ja and zh
        -- }

        -- type
        table.insert(row, table.concat({
            '| style="text-align: center; vertical-align: center; ',
            'background-color: #f2f2f2; border-style: solid none; ',
            'border-width: 1px;" | ', equipCategory}))

        -- {
        -- type stat/attribute
        local attribute_cell = {}
        table.insert(attribute_cell, table.concat({
            '| style="text-align: left; vertical-align: center; ',
            'background-color: #eaeaea; border-style: solid none; ',
            'border-width: 1px;" | '}))
        for _, attrName in ipairs(attrDisplaySequence) do
            local attrValue = equip[attrName]
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
                table.insert(attribute_cell, table.concat({
                    equipAttrIconTable[attrName], attrName, '&nbsp;',
                    attrValue, '&nbsp;'}))
            end
        end -- for ipairs(attrDisplaySequence)
        table.insert(row, table.concat(attribute_cell))
        -- end of type stat/attribute
        --}

        -- range/leng
        local range = equip['射程']
        table.insert(row, table.concat({
            '| style="text-align: center; vertical-align: center; ',
            'background-color: #f2f2f2; border-style: solid none; ',
            'border-width: 1px;" | ', range}))

        -- remarks
        table.insert(row, table.concat({
            '| style="text-align: left; vertical-align: center; ',
            'background-color: #eaeaea; border-style: solid none; ',
            'border-width: 1px;" | ', equip['备注'] or ''}))

    -- append this row to output
    table.insert(output, table.concat(row, '\n'))
    end -- for ipairs(equipIdList)

    output[#output] = output[#output] .. '\n|}'

    return table.concat(output, '\n|-\n')
end

return p
