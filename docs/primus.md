# Primus SDK 文档

## 概述

Primus SDK 提供 zkTLS（零知识传输层安全）技术，实现隐私保护的数据验证。适用于需要验证 Web2 数据但保护用户隐私的 Web3 应用。

## 核心技术

### zkTLS 两种模式

1. **MPC 模式**：多方计算协议，安全性更高
2. **Proxy 模式**：代理模式，性能更好

两种模式都使用 QuickSilver 协议，比其他方案快 10 倍以上。

## SDK 类型

### 1. zkTLS SDK（前端 DApp 使用）

```bash
npm install --save @primuslabs/zktls-js-sdk
```

**主要功能：**
- 验证任意互联网数据
- 生成隐私保护证明
- 提交证明上链

### 2. Core SDK（后端服务器使用）

```bash
npm install --save @primuslabs/zktls-core-sdk
```

**主要功能：**
- 服务端数据验证
- 无需用户交互
- 支持批量验证

## Monad 集成

### 智能合约地址

- **Monad Testnet**: `0x1Ad7fD53206fDc3979C672C0466A1c48AF47B431`

### 合约接口

```solidity
interface IPrimusZKTLS {
    function verifyAttestation(Attestation calldata attestation) external view returns(bool);
}
```

## 主要用例

### 1. 身份验证
- KYC 状态验证
- 账户所有权证明
- 年龄验证（不泄露具体年龄）

### 2. 资产验证
- CEX 账户余额证明
- 代币持有证明
- 交易量证明

### 3. 社交验证
- 粉丝数量证明
- 社交媒体账号验证
- 活跃度证明

### 4. DeFi 应用
- 链下信用评分
- 动态抵押率
- 隐私保护的借贷

## 开发流程

### 1. 在 Developer Hub 创建项目
- 获取 appID 和 appSecret
- 创建验证模板

### 2. 代码实现

#### 前端部分

```javascript
import { PrimusZKTLS } from "@primuslabs/zktls-js-sdk";

// 初始化参数，建议在页面初始化时调用
const primusZKTLS = new PrimusZKTLS();
const appId = "YOUR_APPID";
const initAttestaionResult = await primusZKTLS.init(appId);

// 设备检测（可选）
// let platformDevice = "pc";
// if (navigator.userAgent.toLocaleLowerCase().includes("android")) {
//     platformDevice = "android";
// } else if (navigator.userAgent.toLocaleLowerCase().includes("iphone")) {
//     platformDevice = "ios";
// }
// const initAttestaionResult = await primusZKTLS.init(appId, "", {platform: platformDevice});

console.log("primusProof initAttestaionResult=", initAttestaionResult);

export async function primusProof() {
  // 设置模板ID和用户地址
  const attTemplateID = "YOUR_TEMPLATEID";
  const userAddress = "YOUR_USER_ADDRESS";
  
  // 生成证明请求
  const request = primusZKTLS.generateRequestParams(attTemplateID, userAddress);

  // 设置额外参数（可选）
  const additionParams = JSON.stringify({
    YOUR_CUSTOM_KEY: "YOUR_CUSTOM_VALUE",
  });
  request.setAdditionParams(additionParams);

  // 设置zkTLS模式，默认为代理模式（可选）
  const workMode = "proxytls";
  request.setAttMode({
    algorithmType: workMode,
  });

  // 转换请求对象为字符串
  const requestStr = request.toJsonString();

  // 从后端获取签名响应
  const response = await fetch(`http://YOUR_URL:PORT?YOUR_CUSTOM_PARAMETER`);
  const responseJson = await response.json();
  const signedRequestStr = responseJson.signResult;

  // 开始证明过程
  const attestation = await primusZKTLS.startAttestation(signedRequestStr);
  console.log("attestation=", attestation);

  // 验证签名
  const verifyResult = await primusZKTLS.verifyAttestation(attestation);
  console.log("verifyResult=", verifyResult);

  if (verifyResult === true) {
    // 业务逻辑检查，如证明内容和时间戳检查
    // 执行你的业务逻辑
  } else {
    // 失败时的处理逻辑
  }
}
```

#### 后端示例

```javascript
const express = require("express");
const cors = require("cors");
const { PrimusZKTLS } = require("@primuslabs/zktls-js-sdk");

const app = express();
const port = YOUR_PORT;

// 测试用途，开发者可以修改
app.use(cors());

// 监听客户端签名请求并签署证明请求
app.get("/primus/sign", async (req, res) => {
  const appId = "YOUR_APPID";
  const appSecret = "YOUR_SECRET";

  // 创建 PrimusZKTLS 对象
  const primusZKTLS = new PrimusZKTLS();

  // 通过初始化函数设置 appId 和 appSecret
  await primusZKTLS.init(appId, appSecret);

  // 签署证明请求
  console.log("signParams=", req.query.signParams);
  const signResult = await primusZKTLS.sign(req.query.signParams);
  console.log("signResult=", signResult);

  // 返回签名结果
  res.json({ signResult });
});

app.listen(port, () => {
  console.log(`Server is running at http://localhost:${port}`);
});
```

### 3. 链上验证

#### EVM 智能合约

本节将引导您将 Primus 合约部署并集成到您的 Solidity 项目中。

**安装依赖：**

```bash
# 使用 Hardhat
npm install @primuslabs/zktls-contracts

# 使用 Foundry
forge install primus-labs/zktls-contracts
```

**智能合约部署：**

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 如果使用 Foundry，可以在 remappings.txt 中配置：
// @primuslabs/zktls-contracts=lib/zktls-contracts/

import { IPrimusZKTLS, Attestation } from "@primuslabs/zktls-contracts/src/IPrimusZKTLS.sol";

contract AttestorTest {
    address public primusAddress;

    constructor(address _primusAddress) {
        // 替换为您部署的网络地址
        primusAddress = _primusAddress;
    }

    function verifySignature(Attestation calldata attestation) public view returns(bool) {
        IPrimusZKTLS(primusAddress).verifyAttestation(attestation);

        // 业务逻辑检查，如证明内容和时间戳检查
        // 执行你的业务逻辑
        return true;
    }
}
```

#### 链上交互

以下代码帮助开发者与链上合约进行交互。在完成智能合约开发和部署后使用 zkTLS SDK 完成。

```javascript
// ... 前面的代码 ...

// 开始证明过程
const attestation = await primusZKTLS.startAttestation(signedRequestStr);
console.log("attestation=", attestation);

if (verifyResult === true) {
    // 业务逻辑检查，如证明内容和时间戳检查
    // 执行你的业务逻辑

    // 与智能合约交互
    // 设置合约地址和 ABI
    const contractData = {"YOUR_CONTRACT_ABI_JSON_DATA"};
    const abi = contractData.abi;
    const contractAddress = "YOUR_CONTRACT_ADDRESS_YOU_DEPLOYED";
    
    // 使用 ethers.js 连接智能合约
    const provider = new ethers.providers.JsonRpcProvider("YOUR_RPC_URL");
    const contract = new ethers.Contract(contractAddress, abi, provider);

    try {
        // 调用 verifyAttestation 函数
        const tx = await contract.verifySignature(attestation);
        console.log("Transaction:", tx);
    } catch (error) {
        console.error("Error in verifyAttestation:", error);
    }
} else {
    // 不是 Primus 签名，错误业务逻辑
}
```