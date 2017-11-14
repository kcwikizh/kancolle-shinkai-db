--- Source code of KcWiki "模块:深海舰队函数"
-- Provide lua APIs to get shinkai ship data from "模块:深海舰队数据"
-- https://github.com/kcwikizh/kancolle-shinkai-db/tree/develop/lua
-- Please contact us by github issue
local p = {}
local ships, equips = {}, {}
if mw then
    -- Kcwiki platform
    ships = require('模块:深海舰队数据')
    equips = require('模块:深海装备数据')
else
    ships = require('ships')
    equips = require('equips')
end
local shipDataTable = ships.shipDataTable
local equipDataTable = equips.equipDataTable
local table = {
    concat = table.concat,
    insert = table.insert
}
local string = {
    format = string.format
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
-- @param lastNumIdx: regard last element of args is a number or not.
-- @return (bool, string) : true and the data that user want to get,
-- or false followed by an error message.
local function getDataDirectly (ship, args, lastNumIdx)
    local var = ship

    if lastNumIdx then
        -- convert string -> number with validation
        local lastArg = args[#args]
        local data = tonumber(lastArg)
        if data == nil then
            return false, string.format('最后一个参数不是整数: %s',
                table.concat(args, '|'))
        end
        args[#args] = data
    end

    for i, v in ipairs(args) do
        -- Skip args[1] because it's ship ID.
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


--- Get the ship attribute, specified by args, and maybe contains index at last
-- @param ship: lua table of this ship
-- @param args: frame.args, all parameters by invoke {{#invoke:}} of wiki.
-- @return (bool, string) : true and the data that user want to get,
-- or false followed by an error message.
local function getAttrData (ship, args)
    if #args < 3 then
        return false, string.format('参数个数小于3: %s',
            table.concat(args, '|'))
    end

    if args[3] == '火力' or args[3] == '雷装' then
        return getDataDirectly(ship, args, true)
    end

    return getDataDirectly(ship, args)
end


--- Get the equipments name, specified by id
-- @param equipId: equipment id
-- @return (bool, string) : true and the data that user want to get,
-- or false followed by an error message.
local function getEquipNameById (equipId)
    local equipId = tostring(equipId)
    local equipData = equipDataTable[equipId]

    if equipData == nil then
        return false, string.format('equip ID不存在: %s', equipId)
    end

    local equipName = equipData['中文名']
    if equipName == nil then
        return false, string.format('中文名缺失，equip ID: %s ', equipId)
    end

    return true, equipName 
end


--- Get the equipments, specified by args, and maybe contains index at last
-- @param ship: lua table of this ship
-- @param args: frame.args, all parameters by invoke {{#invoke:}} of wiki.
-- @return (bool, string) : true and the data that user want to get,
-- or false followed by an error message.
local function getEquipData (ship, args)
    if #args < 3 then
        return false, string.format('参数个数小于3: %s',
            table.concat(args, '|'))
    end

    local arg3 = args[3]
    if arg3 == '格数' then
        return getDataDirectly(ship, args)
    end

    if arg3 == '搭载' then
        local result, data = getDataDirectly(ship, args, true)
        if data == '-1' then
            data = ''
        end
        return result, data
    end

    if arg3 == '装备' then
        local result, data = getDataDirectly(ship, args, true)
        if result == false then
            return result, data
        end

        return getEquipNameById(data)
    end

    return false, string.format('第三个参数不正确: %s',
        table.concat(args, '|'))
end


--- Get the number of total planes can carry
-- @param ship: lua table of this ship
-- @param args: frame.args, all parameters by invoke {{#invoke:}} of wiki.
-- @return (bool, string) : true and the number in string format,
-- or false followed by an error message.
local function getPlanesNum (ship)
    local num = 0

    for _, v in ipairs(ship['装备']['搭载']) do
        if type(v) == 'number' then
            if v > 0 then
                num = num + v
            end
        end
    end

    return true, tostring(num)
end


-- A table stores each method to get data
local getShipDataMethodTable = {
    ['日文名'] = getDataDirectly,
    ['中文名'] = getDataDirectly,
    ['完整日文名'] = getDataDirectly,
    ['完整中文名'] = getDataDirectly,
    ['类别'] = getDataDirectly,
    ['属性'] = getAttrData,
    ['装备'] = getEquipData,
    ['搭载量'] = getPlanesNum,
    ['出现海域'] = function ()
        return false, '还不支持出现海域查询'
    end
}


--- Get the ship data by ship id (api_start2)
-- @param frame: all parameters by invoke {{#invoke:}} of wiki.
-- @return string: the formated data, or error messages.
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

    local status, data = getDataMethod(ship, args)
    if status == false then
        return errMsg(data)
    end

    return data
end

return p
