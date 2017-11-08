--- Source code of KcWiki "模块:深海舰队函数"
-- Provide lua APIs to get shinkai ship data from "模块:深海舰队数据"
-- https://github.com/kcwikizh/kancolle-shinkai-db/tree/develop/lua
-- Please contact us by github issue

-- coding style refers to <<Programming in Lua Third Edition>>
-- but indented is 4 spaces.

-- If you are pasting source code to 模块:深海舰队函数
-- You must uncomment this block
--[[
local ships = require('模块:舰娘数据')
local equips = require('模块:舰娘装备数据改')
--]]
-- If you are pasting source code to 模块:深海舰队函数
-- You must comment these 2 lines
local ships = require('ships')
local equips = require('equips')

local table = {
    concat = table.concat
}
local string = {
    format = string.format
}

local ship_data_table = ships.ship_data_table
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


--- Check whether the table has key.
-- @param key: the key to check.
-- @param table: the table to check.
-- @return bool: whether the table has key.
local function has_key (key, table)
    return table[key] ~= nil
end


--- Get the data directly, specified by args
-- @param ship: lua table of this ship
-- @param args: frame.args, all parameters by invoke {{#invoke:}} of wiki.
-- @param last_number_index: regard last element of args is a number or not.
-- @return (bool, string) : true and the data that user want to get,
-- or false followed by an error message.
local function get_data_directly (ship, args, last_number_index)
    local var = ship

    if last_number_index then
        -- convert string -> number with validation
        local last_arg = args[#args]
        local data = tonumber(last_arg)
        if data == nil then
            return false, string.format('最后一个参数不是整数: %s',
                table.concat(args, '|'))
        end
        args[#args] = data
    end

    for i, v in ipairs(args) do
        -- Skip args[1] because it's ship ID.
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


--- Get the ship attribute, specified by args, and maybe contains index at last
-- @param ship: lua table of this ship
-- @param args: frame.args, all parameters by invoke {{#invoke:}} of wiki.
-- @return (bool, string) : true and the data that user want to get,
-- or false followed by an error message.
local function get_attr_data (ship, args)
    if #args < 3 then
        return false, string.format('参数个数小于3: %s',
            table.concat(args, '|'))
    end

    if args[3] == '火力' or args[3] == '雷装' then
        return get_data_directly(ship, args, true)
    end

    return get_data_directly(ship, args)
end


--- Get the equipments name, specified by id
-- @param equip_id: equipment id
-- @return (bool, string) : true and the data that user want to get,
-- or false followed by an error message.
local function get_equip_name_by_id (equip_id)
    local equip_id = tostring(equip_id)
    local equip_data = equip_data_table[equip_id]

    if equip_data == nil then
        return false, string.format('equip ID不存在: %s', equip_id)
    end

    local equip_name = equip_data['中文名']
    if equip_name == nil then
        return false, string.format('中文名缺失，equip ID: %s ', equip_id)
    end

    return true, equip_name 
end


--- Get the equipments, specified by args, and maybe contains index at last
-- @param ship: lua table of this ship
-- @param args: frame.args, all parameters by invoke {{#invoke:}} of wiki.
-- @return (bool, string) : true and the data that user want to get,
-- or false followed by an error message.
local function get_equip_data (ship, args)
    if #args < 3 then
        return false, string.format('参数个数小于3: %s',
            table.concat(args, '|'))
    end

    local arg3 = args[3]
    if arg3 == '格数' then
        return get_data_directly(ship, args)
    end

    if arg3 == '搭载' then
        local result, data = get_data_directly(ship, args, true)
        if data == '-1' then
            data = ''
        end
        return result, data
    end

    if arg3 == '装备' then
        local result, data = get_data_directly(ship, args, true)
        if result == false then
            return result, data
        end

        return get_equip_name_by_id(data)
    end

    return false, string.format('第三个参数不正确: %s',
        table.concat(args, '|'))
end


-- A table stores each method to get data
local get_ship_data_method_table = {
    ['日文名'] = get_data_directly,
    ['中文名'] = get_data_directly,
    ['完整日文名'] = get_data_directly,
    ['完整中文名'] = get_data_directly,
    ['类别'] = get_data_directly,
    ['属性'] = get_attr_data,
    ['装备'] = get_equip_data,
    ['出现海域'] = function ()
        return false, '还不支持出现海域查询'
    end
}


--- Get the ship data by ship id (api_start2)
-- @param frame: all parameters by invoke {{#invoke:}} of wiki.
-- @return string: the formated data, or error messages.
function p.get_ship_by_id (frame)
    local ship = ship_data_table[frame.args[1]]

    if ship == nil then
        return err_msg(string.format('ship ID不存在: %s', frame.args[1]))
    end

    local get_data_method = get_ship_data_method_table[frame.args[2]]
    if get_data_method == nil then
        return err_msg(string.format('第二个参数不正确: %s',
            table.concat(frame.args, '|')))
    end

    local status, data = get_data_method(ship, frame.args)
    if status == false then
        return err_msg(data)
    end

    return data
end
--- Just same with "模块:舰娘函数"
p.getSpDataById = p.get_ship_by_id

return p
