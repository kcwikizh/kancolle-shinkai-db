--- Source code of KcWiki "模块:深海舰队函数"
-- Provide lua APIs to get shinkai ship data from "模块:深海舰队数据"
-- https://github.com/kcwikizh/kancolle-shinkai-db/tree/develop/lua
-- Please contact us by github issue
local p = {}
local ships, equips = {}, {}
if mw then
    -- Kcwiki platform
    ships = require('模块:深海栖舰数据改')
    equips = require('模块:深海装备数据')
else
    ships = require('ships')
    equips = require('equips2')
end
local shipDataTable = ships.shipDataTable
local equipDataTable = equips.equipDataTable
local table = {
    concat = table.concat,
    insert = table.insert
}
local string = {
    format = string.format,
    find = string.find,
    gsub = string.gsub
}
local UNKNOW_RETURN_VALUE = '?'
local planeCategoryTable = {
    [6] = '舰上战斗机',
    [7] = '舰上爆击机',
    [8] = '舰上攻击机',
    [9] = '舰上侦察机',
    [10] = '水上侦察机',
    [11] = '水上爆击机',
    [41] = '大型飞行艇',
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
-- @param ship: lua table of this ship
-- @param args: frame.args, all parameters by invoke {{#invoke:}} of wiki.
-- @param lastNumIdx: weather last element of args is a number or not.
-- @return string: the data that user want to get.
local function getDataDirectly (ship, args, lastNumIdx)
    local var = ship

    if lastNumIdx then
        -- convert string -> number with validation
        local lastArg = args[#args]
        local data = tonumber(lastArg)
        if data == nil then
            error(string.format('最后一个参数不是整数: %s', table.concat(args, '|')))
        end
        args[#args] = data
    end

    for i, v in ipairs(args) do
        -- Skip args[1] because it's ship ID.
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

    return var
end


--- Get the ship suffix
-- @param ship: lua table of this ship
-- @return string: 'elite', 'flagship', '后期型', '后期型elite', '后期型flagship'
local function getSuffix (ship)
    local fullName = ship['中文名']
    local output = ''


    if fullName == nil then
        return output
    end

    if string.find(fullName, '后期型') then
        output = '后期型'
    elseif string.find(fullName, '改') then
        output = '改'
    end

    if string.find(fullName, 'elite') then
        output = output .. 'elite'
    elseif string.find(fullName, 'flagship') then
        output = output .. 'flagship'
    end

    return output
end


--- Get the ship attribute, specified by args, and maybe contains index at last
-- @param ship: lua table of this ship
-- @param args: frame.args, all parameters by invoke {{#invoke:}} of wiki.
-- @return string: the data that user want to get.
local function getAttrData (ship, args)
    if #args < 3 then
        error(string.format('参数个数小于3: %s', table.concat(args, '|')))
    end

    if args[3] == '速力' then
        local soku = getDataDirectly(ship, args)
        local t = {
            [0] = '路基',
            [5] = '低',
            [10] = '高'
        }
        return t[soku] or -1
    end

    if args[3] == '射程' then
        local leng = getDataDirectly(ship, args)
        local t = {
            [0] = '无',
            [1] = '短',
            [2] = '中',
            [3] = '长',
            [4] = '超长',
            [5] = '超超长'
        }
        return t[leng] or -1
    end

    if args[3] == '火力' or args[3] == '雷装' then
        return getDataDirectly(ship, args, true)
    end

    return getDataDirectly(ship, args)
end


--- Get the equipment Lua table, specified by id
-- @param equipId: equipment id
-- @return table: the equipment Lua table
local function getEquipDataById (equipId)
    local equipId = tostring(equipId)
    local equipData = equipDataTable[equipId]

    if equipData == nil then
        error(string.format('equip ID不存在: %s', equipId))
    end

    return equipData
end


--- Get the equipments name, specified by id
-- @param equipId: equipment id
-- @return string: equipment chinese name
local function getEquipNameById (equipId)
    local equipData = getEquipDataById(equipId)

    local equipName = equipData['中文名']
    if equipName == nil then
        error(string.format('中文名缺失，equip ID: %s ', equipId))
    end

    return equipName 
end


--- Get the equipments category, specified by id
-- @param equipId: equipment id
-- @return number: equipment category
local function getEquipCategoryById (equipId)
    local equipData = getEquipDataById(equipId)

    local equipCategory = equipData['类型'][3]
    if equipCategory == nil then
        error(string.format('Category，equip ID: %s ', equipId))
    end

    return equipCategory
end


--- Get the equipments, specified by args, and maybe contains index at last
-- @param ship: lua table of this ship
-- @param args: frame.args, all parameters by invoke {{#invoke:}} of wiki.
-- @return string: the data that user want to get.
local function getEquipData (ship, args)
    if #args < 3 then
        error(string.format('参数个数小于3: %s', table.concat(args, '|')))
    end

    local arg3 = args[3]
    if arg3 == '格数' then
        return getDataDirectly(ship, args)
    end

    if arg3 == '搭载' then
        return getDataDirectly(ship, args, true)
    end

    if arg3 == '装备' then
        return getEquipNameById(getDataDirectly(ship, args, true))
    end

    error(string.format('第三个参数不正确: %s', table.concat(args, '|')))
end


--- Get the number of total planes can carry
-- @param ship: lua table of this ship
-- @param args: frame.args, all parameters by invoke {{#invoke:}} of wiki
-- @return string: the planes number
local function getPlanesNum (ship)
    local num = 0

    for _, v in ipairs(ship['装备']['搭载']) do
        if type(v) == 'number' then
            if v > 0 then
                num = num + v
            end
        end
    end

    return num
end


--- Get the HTML code of equips list for KcWiki template: 深海栖舰
-- @param ship: lua table of this ship
-- @return string : HTML code of equips
local function getEquipListHtml (ship)
    local output = {}

    for i, equipID in ipairs(ship['装备']['装备']) do
        local status, name = pcall(getEquipNameById, equipID)
        if status == false then
            return errMsg(name)
        end

        local slotCapacity = ship['装备']['搭载'][i]
        if slotCapacity and slotCapacity > 0 then
            local status, category = pcall(getEquipCategoryById, equipID)
            if status == false then
                return errMsg(category)
            end

            if planeCategoryTable[category] then
                name = string.format('%s(%d)', name, slotCapacity)
            end
        end

        table.insert(output, string.format('<p>%s</p>', name))
    end

    return table.concat(output)
end


-- A table stores each method to get data spicified by frame.args[2]
local getShipDataMethodTable = {
    ['日文名'] = getDataDirectly,
    ['中文名'] = getDataDirectly,
    ['后缀'] = getSuffix,
    ['kcwiki分类'] = getDataDirectly,
    ['属性'] = getAttrData,
    ['装备'] = getEquipData,
    ['搭载量'] = getPlanesNum,
    ['装备列表'] = getEquipListHtml,
    ['出现海域'] = function ()
        error('还不支持出现海域查询')
    end
}


--- Get the ship data by ship id (api_start2)
-- @param frame: all parameters by invoke {{#invoke:}} of wiki.
-- @return string: the formated data.
function p.getShipDataById (frame)
    -- Something strange that:
    -- frame.args can't be table.concat or passed to deep function as parameter
    -- or it will be an empty table, such as: table.concat(frame.args) -> ''
    -- assign it to a local variable 'args', it works.
    local args = {}
    for _, v in ipairs(frame.args) do
        table.insert(args, v)
    end
    local ship = shipDataTable[args[1]]

    if ship == nil then
        return errMsg(string.format('ship ID不存在: %s', args[1]))
    end

    local getDataMethod = getShipDataMethodTable[args[2]]
    if getDataMethod == nil then
        return errMsg(string.format('第二个参数不正确: %s',
            table.concat(args, '|')))
    end

    local status, data = pcall(getDataMethod, ship, args)
    if status == false then
        return errMsg(data)
    end

    if data == -1 or data == '-1' then
        return UNKNOW_RETURN_VALUE
    else
        return data
    end
end

local function getBasicName (ship, lang)
    local output = ''
    local t = {
        ['zh'] = ship['中文名'],
        ['ja'] = ship['日文名']
    }

    local entire_name = t[lang]
    if entire_name == nil then
        return output
    end

    if lang == 'zh' then
        output = string.gsub(entire_name, '后期型', '')
    else
        output = string.gsub(entire_name, '後期型', '')
    end
    output = string.gsub(output, '改', '')
    output = string.gsub(output, 'elite', '')
    output = string.gsub(output, 'flagship', '')

    return output
end


--- Get the ship name without any suffix (改, 后期型, elite, flagship)
-- @param frame: all parameters by invoke {{#invoke:}} of wiki.
-- @return string: the formated data.
function p.getShipBasicNameById (frame)
    local args = {}
    for _, v in ipairs(frame.args) do
        table.insert(args, v)
    end
    local ship = shipDataTable[args[1]]

    if ship == nil then
        return errMsg(string.format('ship ID不存在: %s', args[1]))
    end

    local lang = args[2] or ''
    if lang ~= 'zh' and lang ~= 'ja' then
        return errMsg(string.format('第二个参数不正确("zh" or "ja"): %s',
            table.concat(args, '|')))
    end

    return getBasicName(ship, lang)
end

return p
