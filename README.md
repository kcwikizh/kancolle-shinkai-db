# kancolle-shinkai-db

开发中……

游戏舰队收藏（舰队これくしょん-舰これ-）中，深海方面的格式化数据、KcWiki Lua函数

提供诸如json、lua格式的原生数据，供其他应用使用

以及KcWiki的Lua API函数

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

### Phase 3
- [x] 深海舰队函数
- [x] 深海装备函数
- [x] 深海舰队模板

### Phase 4
- [ ] Github Wiki
- [ ] KcWiki Doc

### Phase 5（填坑）
- [x] 代码优化
- [x] 从api\_start2直接生成装备数据
- [ ] Python2的支持
