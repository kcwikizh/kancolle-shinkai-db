local ships = require('ships')
local equips = require('equips2')
local ships_method = require('ships_method')
local equips_method = require('equips_method2')

local string = {
    format = string.format
}

local table = {
    concat = table.concat
}

local frame = {
    expandTemplate = function (self, p)
        return string.format('{{%s|%s|%s}}', p.title, p.args[1], p.args[2])
    end
}

function doShipsMethodTest ()
    local testArgsList = {
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
        {'1661', '装备', '装备', '5'},
        {'1661', '装备', '装备', '5', '1'},
        {'1661', '搭载量', '5', '1'}
    }

    for _, v in ipairs(testArgsList) do
        print(string.format('[Invoke] %s', table.concat(v, '|')))
        print('\t' .. ships_method.getShipDataById({args = v}))
    end
end

function doEquipsGetDataTest ()
    print('doEquipsGetDataTest')
    local testArgsList = {
        {'507', '日文名'},
        {'2507', '日文名'},
        {'507', 'a'},
        {'507'},
        {'507', '火力'},
        {'507', '火力1'},
        {'507', '火力', '1'},
        {'507', '类型'},
        {'507', '类别'},
        {'507', '图鉴'},
        {'579', '类别'},
        {'579', '图鉴'},
    }

    for _, v in ipairs(testArgsList) do
        print(string.format('[Invoke] %s', table.concat(v, '|')))
        print('\t' .. equips_method.getEquipDataById({args = v}))
    end
end

function doEquipsGetEquipsListHtml ()
    print('write equips wiki to equips_wiki.xhtml')
    local f = assert(io.open('equips_wiki.xhtml', 'w'))
    f:write(equips_method.getEquipsListHtml(frame))
    f:close()
end

function doEquipsGetEquipsListMeidawiki ()
    print('write equips wiki to equips_wiki.mediawiki')
    local f = assert(io.open('equips_wiki.mediawiki', 'w'))
    f:write(equips_method.getEquipsListMediawiki(frame))
    f:close()
end

function doEquipsMethodTest ()
    doEquipsGetDataTest()
    doEquipsGetEquipsListHtml()
    doEquipsGetEquipsListMeidawiki()
end


function main ()
    doShipsMethodTest()
    doEquipsMethodTest()
end

main()
