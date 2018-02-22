local ships = require('ships')
local equips = require('equips2')
local ships_method = require('ships_method')
local equips_method = require('equips_method2')

local string = {
    format = string.format,
    find = string.find
}
local table = {
    concat = table.concat
}
local frame = {
    expandTemplate = function (self, p)
        return string.format('{{%s|%s|%s}}', p.title, p.args[1], p.args[2])
    end
}


local function functionEquals (source)
    assert(type(source) == 'string' or type(source) == 'number')
    return function (target)
        return source == target
    end
end


local function functionStringContains (source)
    assert(type(source) == 'string' or type(source) == 'number')
    return function (target)
        return string.find(target, source)
    end
end


local function doShipGetDataTest ()
    local testCases = {
        {
            {'1746', '日文名'},
            functionEquals('戦艦仏棲姫')
        },
        {
            {'1746', '属性', '火力', '1'},
            functionEquals(242)
        },
        {
            {'1746', '属性', '火力'},
            functionStringContains('最后一个参数不是整数')
        },
        {
            {'1746', '属性', '火力', 'a'},
            functionStringContains('最后一个参数不是整数')
        },
        {
            {'1746', '属性'},
            functionStringContains('参数个数小于')
        },
        {
            {'1746', '日文名', '1'},
            functionStringContains('参数个数过多')
        },
        {
            {'1746', '出现海域'},
            functionStringContains('还不支持出现海域查询')
        },
        {
            {'1', 'a'},
            functionStringContains('ship ID不存在')
        },
        {
            {'1746', 'a'},
            functionStringContains('第二个参数不正确')
        },
        {
            {'1746', '装备'},
            functionStringContains('参数个数小于3')
        },
        {
            {'1746', '装备', '格数'},
            functionEquals(4)
        },
        {
            {'1746', '装备', 'dd'},
            functionStringContains('第三个参数不正确')
        },
        {
            {'1661', '装备', '搭载', '1'},
            functionEquals(0)
        },
        {
            {'1661', '装备', '搭载', '2'},
            functionEquals(0)
        },
        {
            {'1661', '装备', '搭载', '3'},
            functionEquals(0)
        },
        {
            {'1661', '装备', '搭载', '4'},
            functionEquals(4)
        },
        {
            {'1661', '装备', '搭载', '5'},
            functionStringContains('索引越界')
        },
        {
            {'1661', '装备', '装备', '1'},
            functionEquals('8英寸长射程连装炮')
        },
        {
            {'1661', '装备', '装备', '2'},
            functionEquals('8英寸长射程连装炮')
        },
        {
            {'1661', '装备', '装备', '3'},
            functionEquals('高速深海鱼雷')
        },
        {
            {'1661', '装备', '装备', '4'},
            functionEquals('深海水上侦察观测机')
        },
        {
            {'1661', '装备', '装备', '5'},
            functionStringContains('索引越界')
        },
        {
            {'1661', '装备', '装备', '5', '1'},
            functionStringContains('索引越界')
        },
        {
            {'1661', '搭载量'},
            functionEquals(4)
        },
        {
            {'1661', '搭载量', '5', '1'},
            functionEquals(4)
        },
        {
            {'1631', '属性', '速力'},
            functionEquals('路基')
        },
        {
            {'1766', '属性', '速力'},
            functionEquals('?')
        },
        {
            {'1510', '属性', '射程'},
            functionEquals('无'),
        },
        {
            {'1501', '属性', '射程'},
            functionEquals('短'),
        },
        {
            {'1505', '属性', '射程'},
            functionEquals('中'),
        },
        {
            {'1511', '属性', '射程'},
            functionEquals('长')
        },
        {
            {'1708', '属性', '射程'},
            functionEquals('超长')
        },
        {
            {'1637', '属性', '索敌'},
            functionEquals('?')
        },
        {
            {'1604', '装备列表' },
            functionEquals(table.concat({
                '<p>20英寸连装炮</p>',
                '<p>20英寸连装炮</p>',
                '<p>水上雷达 Mark.II</p>',
                '<p>深海栖舰侦察机(6)</p>'}))
        },
        {
            {'1509', '装备列表' },
            functionEquals(table.concat({
                '<p>8英寸三连装炮</p>',
                '<p>21英寸鱼雷前期型</p>',
                '<p>深海栖舰侦察机(3)</p>'}))
        },
        {
            {'1509', '后缀' },
            functionEquals('')
        },
        {
            {'1734', '后缀' },
            functionEquals('改elite')
        },
        {
            {'1735', '后缀' },
            functionEquals('改flagship')
        },
        {
            {'1742', '后缀' },
            functionEquals('后期型')
        },
        {
            {'1743', '后缀' },
            functionEquals('后期型elite')
        },
        {
            {'1744', '后缀' },
            functionEquals('后期型flagship')
        },
        {
            {'1509', 'kcwiki分类' },
            functionEquals('深海常规舰队 重巡洋舰')
        }
    }

    for _, v in ipairs(testCases) do
        ret = ships_method.getShipDataById({args = v[1]})
        testFunction = v[2]
        if not testFunction(ret) then
            print(string.format('[Invoke] %s', table.concat(v[1], '|')))
            print('Test failed')
            print(table.concat(v[1], '|'))
            print(ret)
            return
        end
    end
    print('doShipGetDataTest pass')
end


local function doShipGetBasicNameTest ()
    local testCases = {
        {
            {'1', 'a'},
            functionStringContains('ship ID不存在')
        },
        {
            {'1746', 'a'},
            functionStringContains('第二个参数不正确')
        },
        {
            {'1746'},
            functionStringContains('第二个参数不正确')
        },
        {
            {'1509', 'zh' },
            functionEquals('重巡RI级')
        },
        {
            {'1509', 'ja' },
            functionEquals('重巡リ級')
        },
        {
            {'1734', 'zh' },
            functionEquals('轻母NU级')
        },
        {
            {'1735', 'zh' },
            functionEquals('轻母NU级')
        },
        {
            {'1742', 'zh' },
            functionEquals('驱逐NA级')
        },
        {
            {'1743', 'zh' },
            functionEquals('驱逐NA级')
        },
        {
            {'1744', 'zh' },
            functionEquals('驱逐NA级')
        },
    }

    for _, v in ipairs(testCases) do
        ret = ships_method.getShipBasicNameById({args = v[1]})
        testFunction = v[2]
        if not testFunction(ret) then
            print(string.format('[Invoke] %s', table.concat(v[1], '|')))
            print('Test failed')
            print(table.concat(v[1], '|'))
            print(ret)
            return
        end
    end
    print('doShipGetBasicNameTest pass')
end


local function doEquipsGetDataTest ()
    local testCases = {
        {
            {'507', '日文名'},
            functionEquals('14inch連装砲')
        },
        {
            {'2507', '日文名'},
            functionStringContains('equip ID不存在')
        },
        {
            {'507', 'a'},
            functionStringContains('索引越界')
        },
        {
            {'507'},
            functionStringContains('参数个数过少')
        },
        {
            {'507', '火力'},
            functionEquals(10)
        },
        {
            {'507', '火力1'},
            functionStringContains('索引越界')
        },
        {
            {'507', '火力', '1'},
            functionStringContains('参数个数过多')
        },
        {
            {'539', '类别'},
            functionEquals(21)
        },
        {
            {'539', '图鉴'},
            functionEquals(15)
        }
    }

    for _, v in ipairs(testCases) do
        ret = equips_method.getEqDataById({args = v[1]})
        testFunction = v[2]
        if not testFunction(ret) then
            print(string.format('[Invoke] %s', table.concat(v[1], '|')))
            print('Test failed')
            print(table.concat(v[1], '|'))
            print(ret)
            return
        end
    end
    print('doEquipsGetDataTest pass')
end


local function doEquipsGetEquipsListHtml ()
    print('write equips wiki to equips_wiki.xhtml')
    local f = assert(io.open('equips_wiki.xhtml', 'w'))
    f:write(equips_method.getEquipsListHtml(frame))
    f:close()
end


local function doEquipsGetEquipsListMeidawiki ()
    print('write equips wiki to equips_wiki.mediawiki')
    local f = assert(io.open('equips_wiki.mediawiki', 'w'))
    f:write(equips_method.getEquipsListMediawiki(frame))
    f:close()
end

local function doShipGetEquipListHtml ()
    print(ships_method.getShipDataById(
        {
            args = {'1711', '装备列表'}
        }))
end


local function doShipsMethodTest ()
    doShipGetDataTest()
    doShipGetBasicNameTest()
    doShipGetEquipListHtml()
end


local function doEquipsMethodTest ()
    doEquipsGetDataTest()
    doEquipsGetEquipsListHtml()
    doEquipsGetEquipsListMeidawiki()
end


local function main ()
    doShipsMethodTest()
    doEquipsMethodTest()
end

main()
