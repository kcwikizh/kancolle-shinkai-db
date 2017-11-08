local ships = require('ships')
local equips = require('equips')
local ships_method = require('ships_method')
local equips_method = require('equips_method')

local string = {
    format = string.format
}

local table = {
    concat = table.concat
}

function do_ships_method_test ()
    local test_args_list = {
        {'1746', '日文名'},
        {'1746', '属性', '火力', '1'},
        {'1746', '属性', '火力'},
        {'1746', '属性', '火力', 'a'},
        {'1746', '属性'},
        {'1746', '日文名', '1'},
        {'1746', '出现海域'},
        {'1', 'a'},
        {'1746', 'a'},
        {'1746', '装备'},
        {'1746', '装备', '格数'},
        {'1746', '装备', 'dd'},
        {'1661', '装备', '搭载', '1'},
        {'1661', '装备', '搭载', '2'},
        {'1661', '装备', '搭载', '3'},
        {'1661', '装备', '搭载', '4'},
        {'1661', '装备', '搭载', '5'},
        {'1661', '装备', '装备', '1'},
        {'1661', '装备', '装备', '2'},
        {'1661', '装备', '装备', '3'},
        {'1661', '装备', '装备', '4'},
        {'1661', '装备', '装备', '5'}
    }

    for _, v in ipairs(test_args_list) do
        print(string.format('[Invoke] %s', table.concat(v, '|')))
        print('\t' .. ships_method.getSpDataById({args = v}))
    end
end

function do_equips_get_data_test ()
    print('do_equips_get_data_test')
    local test_args_list = {
        {'507', '日文名'},
        {'2507', '日文名'},
        {'507', 'a'},
        {'507'},
        {'507', '属性', '火力'},
        {'507', '属性', '火力1'},
        {'507', '属性'}
    }

    for _, v in ipairs(test_args_list) do
        print(string.format('[Invoke] %s', table.concat(v, '|')))
        print('\t' .. equips_method.getEqDataById({args = v}))
    end
end

function do_equips_get_equips_list_wiki ()
    print(equips_method.get_equips_list_wiki())
end

function do_equips_method_test ()
    -- do_equips_get_data_test()
    do_equips_get_equips_list_wiki()
end


function main ()
    -- do_ships_method_test()
    do_equips_method_test()
end

main()