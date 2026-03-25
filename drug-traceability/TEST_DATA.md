# 测试数据说明

## 数据库位置

**前端项目 `drug-traceability-frontend` 和后端项目 `drug-traceability` 共享同一个数据库：**

- **数据库名称**：`drug_traceability`
- **数据库地址**：`localhost:3306`
- **用户名**：`root`
- **密码**：`root`（请根据您的实际 MySQL 配置修改）

## 如何添加测试数据

### 方法1：使用 MySQL Workbench（推荐）

1. 打开 MySQL Workbench
2. 连接到本地 MySQL 服务器
3. 打开 SQL 文件：`c:\dev\design\init_db.sql`
4. 点击执行按钮（⚡）

### 方法2：使用命令行

```bash
mysql -u root -p drug_traceability < c:\dev\design\init_db.sql
```

### 方法3：在 MySQL 命令行中执行

```sql
source c:/dev/design/init_db.sql;
```

## init_db.sql 文件说明

[init_db.sql](file:///c:/dev/design/init_db.sql) 文件包含：
1. **数据库创建语句**
2. **14个表的结构定义**
3. **初始角色和用户数据**
4. **完整的测试数据**（药品、生产批次、库存、采购、销售、用药记录、不良反应、追溯记录、AI相关数据）

## 测试数据内容

| 数据类型 | 记录数量 | 说明 |
|---------|---------|------|
| 药品信息 | 13种 | D001-D013 |
| 生产批次 | 13个 | B001-B013 |
| 库存记录 | 25条 | 覆盖所有批次 |
| 采购记录 | 15条 | 药品经营企业采购 |
| 销售记录 | 15条 | 药品经营企业销售 |
| 用药记录 | 10条 | 不同患者用药情况 |
| 不良反应 | 10条 | 不同药品不良反应 |
| 追溯记录 | 72条 | 完整追溯链路 |
| AI会话 | 10条 | 不同主题咨询 |
| AI消息 | 40条 | 完整对话记录 |
| AI知识文档 | 13条 | 药品信息 |
| AI工具调用日志 | 23条 | 工具使用记录 |

## 验证数据

执行以下 SQL 查询验证数据是否添加成功：

```sql
SELECT COUNT(*) FROM drug_info;           -- 应返回 13
SELECT COUNT(*) FROM production_batch;    -- 应返回 13
SELECT COUNT(*) FROM inventory;           -- 应返回 25
SELECT COUNT(*) FROM procurement_record;  -- 应返回 15
SELECT COUNT(*) FROM sale_record;         -- 应返回 15
SELECT COUNT(*) FROM usage_record;        -- 应返回 10
SELECT COUNT(*) FROM adverse_reaction;    -- 应返回 10
SELECT COUNT(*) FROM trace_record;        -- 应返回 72
SELECT COUNT(*) FROM ai_conversation;     -- 应返回 10
SELECT COUNT(*) FROM ai_message;          -- 应返回 40
SELECT COUNT(*) FROM ai_knowledge_doc;    -- 应返回 13
SELECT COUNT(*) FROM ai_tool_usage_log;   -- 应返回 23
```

## 注意事项

1. **先备份数据**：执行 SQL 脚本前建议备份现有数据
2. **检查表结构**：确保所有表已创建且结构正确
3. **外键约束**：数据插入顺序很重要，SQL 脚本已按正确顺序排列
4. **MySQL 密码**：如果您的 MySQL 密码不是 `root`，请修改 SQL 脚本中的密码
