# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

使用 zkTLS 进行身份验证的 Token 分发系统，利用 Primus SDK 实现隐私保护的数据验证。

## 技术栈

- **前端框架**: Next.js + TypeScript
- **UI 组件库**: Shadcn UI  
- **智能合约**: Foundry
- **密码学层**: Primus SDK (zkTLS/zkFHE) 文档： @docs/primus.md
- **包管理器**: Bun
- **构建工具**: Vite

## 常用命令

### 项目初始化
```bash
# 创建 Next.js 项目
bunx create-next-app@latest . --typescript --tailwind --app

# 安装依赖
bun install

# 初始化 Shadcn UI
bunx shadcn-ui@latest init
```

### 开发命令
```bash
# 启动开发服务器
bun dev

# 构建生产版本
bun run build

# 运行生产版本
bun start

# 代码检查
bun run lint

# 类型检查
bun run type-check
```

### 智能合约开发 (Foundry)
```bash
# 安装合约依赖
forge install

# 编译合约
forge build

# 运行测试
forge test

# 运行特定测试
forge test --match-test testName

# 启动本地 Anvil 节点
make anvil

# 部署 V2 合约到本地
make deploy-local-v2
```

## 项目结构

### 前端架构
- `/app` - Next.js 13+ App Router 页面和布局
- `/components` - 可复用的 React 组件（使用 Shadcn UI）
- `/lib` - 工具函数和 Primus SDK 集成
- `/hooks` - zkTLS 功能的自定义 React hooks

### 智能合约
- `/contracts` - Solidity 智能合约
- `/script` - 部署脚本
- `/test` - 合约测试

### Primus SDK 集成要点
- 支持 Proxy TLS 和 MPC TLS 两种模式
- 需要从 Primus Developer Hub 获取 appID 和 appSecret
- 认证结果包含接收者、请求详情、响应数据和签名

## 重要开发规范

### 代码风格
- 代码必须极其简短，但完美完成任务
- UI 风格要求简洁优雅大气
- 追求用最少代码实现 100% 功能

### 环境变量处理
- 绝不直接读写 `.env` 文件
- 参考 `.env.template` 了解所需变量
- 编写防御式代码检测环境变量配置
- monorepo 场景下使用根目录 `.env`，必要时通过 Makefile 复制

### Primus SDK 使用注意
- 配置验证参数时注意选择合适的 zkTLS 模式
- 验证所有认证签名后才能信任数据

## 支持的区块链
- Monad Testnet

## 网络信息
### Monad Testnet
- **网络名称**: Monad Testnet
- **Chain ID**: 10143
- **货币符号**: MON
- **区块浏览器**: https://testnet.monadexplorer.com

### 公共 RPC 端点
| RPC URL | 提供者 | 请求限制 | 批处理调用限制 | 其他限制 |
|---------|--------|----------|----------------|----------|
| https://testnet-rpc.monad.xyz | QuickNode | 25 请求/秒 | 100 | - |
| https://rpc.ankr.com/monad_testnet | Ankr | 300 请求/10 秒，12000 请求/10 分钟 | 100 | 不允许 debug_* 方法 |
| https://rpc-testnet.monadinfra.com | Monad Foundation | 20 请求/秒 | 不允许 | 不允许 eth_getLogs 和 debug_* 方法 |

## AI 开发辅助信息

### 常见开发问题和解决方案
1. **环境配置问题**: Primus SDK 需要正确的 appId/appSecret，使用 `/api/zktls/config` 端点安全传递
2. **客户端兼容性**: Next.js SSR 环境下使用动态导入：`await import('@primuslabs/zktls-js-sdk')`
4. **数据解析问题**: Twitter API 使用固定模板 ID 和 JSON Path `$.screen_name`

### 关键配置参数
- **Monad Testnet Primus 合约**: `0x1Ad7fD53206fDc3979C672C0466A1c48AF47B431`
- **Twitter 验证模板 ID**: `2e3160ae-8b1e-45e3-8c59-426366278b9d`