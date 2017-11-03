# kancolle-shinkai-db

开发中……

游戏舰队收藏（舰队これくしょん-舰これ-）中，深海方面的格式化数据、KcWiki Lua函数

提供诸如nedb、json、lua格式的原生数据，供其他应用使用

以及KcWiki的Lua函数

---

## 开发计划：

### Phase 1
- [x] 工具:从KcWiki上现有的深海数据，获得深海舰队信息和装备信息，python格式
- [x] 生成基础数据json
- [x] 从json数据生成深海舰队的KcWiki Lua（mediawiki Lua）格式数据
- [x] **重要**：与KcWiki技术部确定KcWiki Lua（mediawiki Lua）的格式

### Phase 2
- [x] 与实际数据进行对比，添加海域出现信息，甲乙丙
- [x] 生成海域信息json，并将信息抽象加入到lua中
- [x] **重要**：与KcWiki技术部确定KcWiki Lua（mediawiki Lua）的格式
- [x] 更新到KcWiki

### Phase 3（啥玩意儿啊，咋回事啊，那咋整啊，大佬帮帮忙啊）
- [x] 深海舰队函数
- [ ] 深海舰队函数说明文档
- [ ] 深海装备函数

### Phase 4（填坑）
- [ ] 代码优化
- [ ] Python2的支持
- [ ] 工具：从json直接生成KcWiki的“深海列表”页面
- [ ] 工具：从json直接生成KcWIki的“装备列表”页面

~~flag： 完成Phase 2就买块Dell P2417H~~
