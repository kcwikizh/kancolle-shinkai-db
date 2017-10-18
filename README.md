# kancolle-shinkai-db

开发中……

游戏舰队收藏（舰队これくしょん-舰これ-）中，深海方面的格式化数据以及转换工具
提供诸如json、lua格式的原生数据，供其他应用使用

---

## 开发计划：

### Phase 1
- [ ] 工具:从KcWiki上现有的深海数据，获得深海舰队信息和装备信息，python格式
- [ ] 与实际数据进行对比，确定还需要哪些信息，例如甲乙丙难度如何区分
- [ ] 生成json

### Phase 2
- [ ] **重要**：与KcWiki技术部确定KcWiki Lua（mediawiki Lua）的格式
- [ ] 从json数据生成深海舰队的KcWiki Lua（mediawiki Lua）格式数据
- [ ] 更新到KcWiki

### Phase 3（填坑）
- [ ] Python2的支持
- [ ] 工具：从json直接生成KcWiki的“深海列表”页面
- [ ] 工具：从json直接生成KcWIki的“装备列表”页面

~~flag： 完成Phase 2就买块Dell P2417H~~