---
layout: post
title: TON 合约开发个人经历(4)
date: 2025-04-11 17:30:32
tags: Ton Func
categories: Ton 合约开发
---
# TON 智能合约开发经验分享

## 合约包装
### 以下是前端 / 脚本侧对合约的调用逻辑封装

#### MainContractConfig.ts

```typescript
import { Address, beginCell, Cell } from "@ton/core";

export type MainContractConfig = {
  total_deposits: number;
  owner_address: Address;
  deposits: Cell | null;
};

/**
 * 将给定的 `MainContractConfig` 对象转换为 `Cell`。
 *
 * 该函数接受一个配置对象，并将其属性（一个 32 位无符号整数和一个地址）存储到一个 `Cell` 中，
 * 然后返回这个 `Cell`。
 *
 * @param {MainContractConfig} config - 包含要存储的数据的配置对象。该对象应包含以下属性：
 *   - `number` (number): 要作为 32 位无符号整数存储的数字。
 *   - `address` (Address): 要存储的地址。
 *
 * @returns {Cell} 返回存储了配置数据的 `Cell` 对象。
 *
 * @throws {Error} 如果输入的 `config` 无效或不符合预期结构，将抛出错误。
 */
export function mainContractConfigToCell(config: MainContractConfig): Cell {
  return beginCell()
    .storeUint(config.total_deposits, 32)
    .storeAddress(config.owner_address)
    .storeMaybeRef(config.deposits)
    .endCell();
}
```
<!--more-->
#### JettonWallet.ts
```typescript
import {
    Address,
    beginCell,
    Cell,
    Contract,
    contractAddress,
    ContractProvider,
    Sender,
    SendMode,
    toNano,
} from '@ton/core';

export type JettonWalletConfig = {};

export function jettonWalletConfigToCell(config: JettonWalletConfig): Cell {
    return beginCell().endCell();
}

export class JettonWallet implements Contract {
    constructor(
        readonly address: Address,
        readonly init?: { code: Cell; data: Cell },
    ) {}

    static createFromAddress(address: Address) {
        return new JettonWallet(address);
    }

    static createFromConfig(config: JettonWalletConfig, code: Cell, workchain = 0) {
        console.log(config, '===========+> config');
        const data = jettonWalletConfigToCell(config);
        const init = { code, data };
        return new JettonWallet(contractAddress(workchain, init), init);
    }

    async sendDeploy(provider: ContractProvider, via: Sender, value: bigint) {
        console.log(via, '===========+> via');
        await provider.internal(via, {
            value,
            sendMode: SendMode.PAY_GAS_SEPARATELY,
            body: beginCell().endCell(),
        });
    }

    async getJettonBalance(provider: ContractProvider) {
        let state = await provider.getState();
        if (state.state.type !== 'active') {
            return 0n;
        }
        let res = await provider.get('get_wallet_data', []);
        return res.stack.readBigNumber();
    }
    static transferMessage(
        jetton_amount: bigint,
        to: Address,
        responseAddress: Address,
        customPayload: Cell,
        forward_ton_amount: bigint,
        forwardPayload: Cell,
    ) {
        return beginCell()
            .storeUint(0xf8a7ea5, 32)
            .storeUint(0, 64) // op, queryId
            .storeCoins(jetton_amount)
            .storeAddress(to)
            .storeAddress(responseAddress)
            .storeMaybeRef(customPayload)
            .storeCoins(forward_ton_amount)
            .storeMaybeRef(forwardPayload)
            .endCell();
    }
    async sendTransfer(
        provider: ContractProvider,
        via: Sender,
        value: bigint,
        jetton_amount: bigint,
        to: Address,
        responseAddress: Address,
        customPayload: Cell,
        forward_ton_amount: bigint,
        forwardPayload: Cell,
    ) {
        await provider.internal(via, {
            sendMode: SendMode.PAY_GAS_SEPARATELY,
            body: JettonWallet.transferMessage(
                jetton_amount,
                to,
                responseAddress,
                customPayload,
                forward_ton_amount,
                forwardPayload,
            ),
            value: value,
        });
    }

    /*
      burn#595f07bc query_id:uint64 amount:(VarUInteger 16)
                    response_destination:MsgAddress custom_payload:(Maybe ^Cell)
                    = InternalMsgBody;
    */
    static burnMessage(jetton_amount: bigint, responseAddress: Address, customPayload: Cell) {
        return beginCell()
            .storeUint(0x595f07bc, 32)
            .storeUint(0, 64) // op, queryId
            .storeCoins(jetton_amount)
            .storeAddress(responseAddress)
            .storeMaybeRef(customPayload)
            .endCell();
    }

    async sendBurn(
        provider: ContractProvider,
        via: Sender,
        value: bigint,
        jetton_amount: bigint,
        responseAddress: Address,
        customPayload: Cell,
    ) {
        await provider.internal(via, {
            sendMode: SendMode.PAY_GAS_SEPARATELY,
            body: JettonWallet.burnMessage(jetton_amount, responseAddress, customPayload),
            value: value,
        });
    }
    /*
      withdraw_tons#107c49ef query_id:uint64 = InternalMsgBody;
    */
    static withdrawTonsMessage() {
        return beginCell()
            .storeUint(0x6d8e5e3c, 32)
            .storeUint(0, 64) // op, queryId
            .endCell();
    }

    async sendWithdrawTons(provider: ContractProvider, via: Sender) {
        await provider.internal(via, {
            sendMode: SendMode.PAY_GAS_SEPARATELY,
            body: JettonWallet.withdrawTonsMessage(),
            value: toNano('0.1'),
        });
    }
    /*
      withdraw_jettons#10 query_id:uint64 wallet:MsgAddressInt amount:Coins = InternalMsgBody;
    */
    static withdrawJettonsMessage(from: Address, amount: bigint) {
        return beginCell()
            .storeUint(0x768a50b2, 32)
            .storeUint(0, 64) // op, queryId
            .storeAddress(from)
            .storeCoins(amount)
            .storeMaybeRef(null)
            .endCell();
    }

    async sendWithdrawJettons(provider: ContractProvider, via: Sender, from: Address, amount: bigint) {
        await provider.internal(via, {
            sendMode: SendMode.PAY_GAS_SEPARATELY,
            body: JettonWallet.withdrawJettonsMessage(from, amount),
            value: toNano('0.1'),
        });
    }
}
```

#### JettonMinter.ts
```typescript
import {
    Address,
    beginCell,
    Cell,
    Contract,
    contractAddress,
    ContractProvider,
    Sender,
    SendMode,
    toNano,
} from '@ton/core';

export type JettonMinterContent = {
    type: 0 | 1;
    uri: string;
};
export type JettonMinterConfig = { admin: Address; content: Cell; wallet_code: Cell };

export function jettonMinterConfigToCell(config: JettonMinterConfig): Cell {
    return beginCell()
        .storeCoins(0)
        .storeAddress(config.admin)
        .storeRef(config.content)
        .storeRef(config.wallet_code)
        .endCell();
}

export function jettonContentToCell(content: JettonMinterContent) {
    return beginCell()
        .storeUint(content.type, 8)
        .storeStringTail(content.uri) //Snake logic under the hood
        .endCell();
}

export class JettonMinter implements Contract {
    constructor(
        readonly address: Address,
        readonly init?: { code: Cell; data: Cell },
    ) {}

    static createFromAddress(address: Address) {
        return new JettonMinter(address);
    }

    static createFromConfig(config: JettonMinterConfig, code: Cell, workchain = 0) {
        const data = jettonMinterConfigToCell(config);
        const init = { code, data };
        return new JettonMinter(contractAddress(workchain, init), init);
    }

    async sendDeploy(provider: ContractProvider, via: Sender, value: bigint) {
        await provider.internal(via, {
            value,
            sendMode: SendMode.PAY_GAS_SEPARATELY,
            body: beginCell().endCell(),
        });
    }

    static mintMessage(to: Address, jetton_amount: bigint, forward_ton_amount: bigint, total_ton_amount: bigint) {
        return beginCell()
            .storeUint(0x1674b0a0, 32)
            .storeUint(0, 64) // op, queryId
            .storeAddress(to)
            .storeCoins(jetton_amount)
            .storeCoins(forward_ton_amount)
            .storeCoins(total_ton_amount)
            .endCell();
    }
    async sendMint(
        provider: ContractProvider,
        via: Sender,
        to: Address,
        jetton_amount: bigint,
        forward_ton_amount: bigint,
        total_ton_amount: bigint,
    ) {
        await provider.internal(via, {
            sendMode: SendMode.PAY_GAS_SEPARATELY,
            body: JettonMinter.mintMessage(to, jetton_amount, forward_ton_amount, total_ton_amount),
            value: total_ton_amount + toNano('0.1'),
        });
    }

    /* provide_wallet_address#2c76b973 query_id:uint64 owner_address:MsgAddress include_address:Bool = InternalMsgBody;
     */
    static discoveryMessage(owner: Address, include_address: boolean) {
        return beginCell()
            .storeUint(0x2c76b973, 32)
            .storeUint(0, 64) // op, queryId
            .storeAddress(owner)
            .storeBit(include_address)
            .endCell();
    }

    async sendDiscovery(
        provider: ContractProvider,
        via: Sender,
        owner: Address,
        include_address: boolean,
        value: bigint = toNano('0.1'),
    ) {
        await provider.internal(via, {
            sendMode: SendMode.PAY_GAS_SEPARATELY,
            body: JettonMinter.discoveryMessage(owner, include_address),
            value: value,
        });
    }

    static changeAdminMessage(newOwner: Address) {
        return beginCell()
            .storeUint(0x4840664f, 32)
            .storeUint(0, 64) // op, queryId
            .storeAddress(newOwner)
            .endCell();
    }

    async sendChangeAdmin(provider: ContractProvider, via: Sender, newOwner: Address) {
        await provider.internal(via, {
            sendMode: SendMode.PAY_GAS_SEPARATELY,
            body: JettonMinter.changeAdminMessage(newOwner),
            value: toNano('0.1'),
        });
    }
    static changeContentMessage(content: Cell) {
        return beginCell()
            .storeUint(0x5773d1f5, 32)
            .storeUint(0, 64) // op, queryId
            .storeRef(content)
            .endCell();
    }

    async sendChangeContent(provider: ContractProvider, via: Sender, content: Cell) {
        await provider.internal(via, {
            sendMode: SendMode.PAY_GAS_SEPARATELY,
            body: JettonMinter.changeContentMessage(content),
            value: toNano('0.1'),
        });
    }
    async getWalletAddress(provider: ContractProvider, owner: Address): Promise<Address> {
        const res = await provider.get('get_wallet_address', [
            { type: 'slice', cell: beginCell().storeAddress(owner).endCell() },
        ]);
        return res.stack.readAddress();
    }

    async getJettonData(provider: ContractProvider) {
        let res = await provider.get('get_jetton_data', []);
        let totalSupply = res.stack.readBigNumber();
        let mintable = res.stack.readBoolean();
        let adminAddress = res.stack.readAddress();
        let content = res.stack.readCell();
        let walletCode = res.stack.readCell();
        return {
            totalSupply,
            mintable,
            adminAddress,
            content,
            walletCode,
        };
    }

    async getTotalSupply(provider: ContractProvider) {
        let res = await this.getJettonData(provider);
        return res.totalSupply;
    }
    async getAdminAddress(provider: ContractProvider) {
        let res = await this.getJettonData(provider);
        return res.adminAddress;
    }
    async getContent(provider: ContractProvider) {
        let res = await this.getJettonData(provider);
        return res.content;
    }
}
```

#### MainContract.ts
```typescript
import { Address, beginCell, Cell, Contract, contractAddress, ContractProvider, Sender, SendMode } from '@ton/core';
import { MainContractConfig, mainContractConfigToCell } from './MainContractConfig';

export class MainContract implements Contract {
    constructor(
        readonly address: Address,
        readonly init?: { code: Cell; data: Cell },
    ) {}

    static createFromConfig(config: MainContractConfig, code: Cell, workchain = 0) {
        const data = mainContractConfigToCell(config);
        const init = { code, data };
        const address = contractAddress(workchain, init);

        return new MainContract(address, init);
    }

    async sendIncrement(provider: ContractProvider, sender: Sender, value: bigint, increment_by: number) {
        const msg_body = beginCell()
            .storeUint(4, 32) // OP code
            .storeUint(increment_by, 32) // increment_by value
            .endCell();

        await provider.internal(sender, {
            value,
            sendMode: SendMode.PAY_GAS_SEPARATELY,
            body: msg_body,
        });
    }

    async getData(provider: ContractProvider) {
        const { stack } = await provider.get('get_contract_storage_data', []);
        return {
            total_deposits: stack.readNumber(),
            owner_address: stack.readAddress(),
            deposits: stack.readCell(), // 可选引用，null 或 cell
            ttt_master_addr: stack.readAddress(),
        };
    }

    async getBalance(provider: ContractProvider) {
        const { stack } = await provider.get('balance', []);
        return {
            number: stack.readNumber(),
        };
    }

    //存款场景：
    // 当你发送一个包含 value 的消息时，这个金额会自动转入合约
    // 由于使用 SendMode.PAY_GAS_SEPARATELY，
    // gas 费用会从 value 中单独扣除
    // 剩余的 value 会作为存款金额转入合约

    async sendDeposit(provider: ContractProvider, sender: Sender, value: bigint) {
        const msg_body = beginCell()
            .storeUint(5, 32) // OP code 2为存款 操作码
            .endCell();

        await provider.internal(sender, {
            value,
            // PAY_GAS_SEPARATELY (值为1) 表示 gas 费用将从消息值中单独扣除
            // 这意味着转账金额和 gas 费用是分开计算的

            // 实际效果
            // 假设要转账 1 TON
            // gas 费用是 0.01 TON
            // 接收方会收到完整的 1 TON
            // gas 费用 0.01 TON 会额外扣除
            sendMode: SendMode.PAY_GAS_SEPARATELY,
            body: msg_body,
        });
    }

    async sendNoCodeDeposit(provider: ContractProvider, sender: Sender, value: bigint) {
        const msg_body = beginCell().endCell();

        await provider.internal(sender, {
            value,
            sendMode: SendMode.PAY_GAS_SEPARATELY,
            body: msg_body,
        });
    }

    // 提款场景：
    // 需要明确告诉合约要提取多少金额（amount）
    // value 只用于支付 gas 费用
    // 实际的提款金额需要在消息体中通过 storeCoins(amount) 指定
    async sendWithdrawalRequest(
        provider: ContractProvider,
        sender: Sender, // 发送者即为合约的owner
        value: bigint, // gas 费用
        amount: bigint, // 提款金额
    ) {
        const msg_body = beginCell()
            .storeUint(6, 32) // OP code 3为提款 操作码
            .storeCoins(amount) // 存储要提取的金额
            .endCell();

        await provider.internal(sender, {
            value,
            sendMode: SendMode.PAY_GAS_SEPARATELY,
            body: msg_body,
        });
    }

    async sendClaimInterest(provider: ContractProvider, sender: Sender, bankWalletAddress: Address, value: bigint) {
        const msg_body = beginCell()
            .storeUint(7, 32) // OP code 7为领取利息 操作码
            .storeAddress(bankWalletAddress) // 
            .endCell();

        await provider.internal(sender, {
            value,
            sendMode: SendMode.PAY_GAS_SEPARATELY,
            body: msg_body,
        });
    }

    async sendDeploy(provider: ContractProvider, via: Sender, value: bigint) {
        await provider.internal(via, {
            value,
            sendMode: SendMode.PAY_GAS_SEPARATELY,
            body: beginCell().endCell(),
        });
    }

    async getUserDeposit(provider: ContractProvider, user_address: Address) {
        const { stack } = await provider.get('get_user_deposit', [
            {
                type: 'slice',
                cell: beginCell().storeAddress(user_address).endCell(),
            },
        ]);
        return {
            amount: stack.readBigNumber(),
            timestamp: stack.readNumber(),
        };
    }

    async getUserInterest(provider: ContractProvider, user_address: Address) {
        const { stack } = await provider.get('get_user_interest', [
            {
                type: 'slice',
                cell: beginCell().storeAddress(user_address).endCell(),
            },
        ]);
        return {
            interest: stack.readBigNumber(),
        };
    }

    async getClaimableInterest(provider: ContractProvider, user_address: Address) {
        const { stack } = await provider.get('get_claimable_interest', [
            {
                type: 'slice',
                cell: beginCell().storeAddress(user_address).endCell(),
            },
        ]);
        return {
            accumulatedInterest: stack.readBigNumber(),
            newInterest: stack.readBigNumber(),
        };
    }
}

```

## 合约测试
#### test/main.spec.ts

```typescript
import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { address, beginCell, Cell, toNano } from '@ton/core';
import { MainContract } from '../wrappers/MainContract';
import '@ton/test-utils';
import { compile } from '@ton/blueprint';
import { jettonContentToCell, JettonMinter } from '../wrappers/JettonMinter';
import { JettonWallet } from '../wrappers/JettonWallet';
import * as fs from 'fs';
import * as path from 'path';

// Setup logging
const logFile = path.join(__dirname, 'test.log');
const logStream = fs.createWriteStream(logFile, { flags: 'a' });

function log(message: string) {
    const timestamp = new Date().toISOString();
    const logMessage = `[${timestamp}] ${message}\n`;
    console.log(message);
    logStream.write(logMessage);
}

describe('Main', () => {
    let code: Cell;
    let tttMintCode: Cell;
    let tttWalletCode: Cell;

    beforeAll(async () => {
        // Clear log file at the start of tests
        fs.writeFileSync(logFile, '');
        log('Starting test suite...');
        code = await compile('MainContract');
        tttMintCode = await compile('JettonMinter');
        tttWalletCode = await compile('JettonWallet');
    });

    afterAll(() => {
        log('Test suite completed');
        logStream.end();
    });

    let blockchain: Blockchain;
    let bankMainDeployer: SandboxContract<TreasuryContract>;
    let tttCoinDeployer: SandboxContract<TreasuryContract>;
    let userA_Wallet: SandboxContract<TreasuryContract>;
    let bankMain: SandboxContract<MainContract>;
    let tttCoinMain: SandboxContract<JettonMinter>;

    beforeEach(async () => {
        blockchain = await Blockchain.create();
        blockchain.verbosity = {
            blockchainLogs: false,
            vmLogs: 'vm_logs',
            debugLogs: true,
            print: true,
        };

        const content = jettonContentToCell({
            type: 1,
            uri: 'https://copper-surviving-marsupial-230.mypinata.cloud/ipfs/bafkreiavbpwcz6kgvvvehp55mublcqnuqroigzrwm7g3dn3ekoht26fucq',
        });

        bankMainDeployer = await blockchain.treasury('bankMainDeployer');
        tttCoinDeployer = await blockchain.treasury('tttCoinDeployer');
        userA_Wallet = await blockchain.treasury('userA_Wallet');
        

        tttCoinMain = blockchain.openContract(
            // 这里的admin content wallet_code 都会在部署时存在TON链的C4存储器里
            JettonMinter.createFromConfig(
                {
                    admin: tttCoinDeployer.address,
                    content,
                    wallet_code: tttWalletCode, // 钱包的构造代码
                },
                tttMintCode, // 代币的构造代码
            ),
        );

        // 部署tttCoinMain
        const tttDeployResult = await tttCoinMain.sendDeploy(tttCoinDeployer.getSender(), toNano('0.1'));


        // 这里卡了时间很久 初始化数据给C4时
        // 一定要记住顺序 如下 2个点
        // export function mainContractConfigToCell(config: MainContractConfig): Cell {
        //   return beginCell()
        //   .storeUint(config.total_deposits, 32)
        //   .storeAddress(config.owner_address)
        //   .storeRef(config.deposits ?? beginCell().endCell())
        //   .endCell();
        // }
        // 1 数据要和load的数据顺序一致
        // 2 数据要和load的数据类型一致
        // 合约中  return (
        //          ds~load_uint(32),      ;; 1. total_deposits: 总存款金额（可选，用于统计）
        //          ds~load_msg_addr(),    ;; 2. owner_address: 合约所有者地址
        //          ds~load_ref(),         ;; 3. deposits: 存款字典（cell 类型）
        //         );
        // deposits 是cell类型 所以需要用beginCell().endCell() 包裹 我之前使用的是null 所以一直报错 tvm exit code 9 内存溢出
        bankMain = blockchain.openContract(
            MainContract.createFromConfig(
                {
                    total_deposits: 0,
                    owner_address: bankMainDeployer.address,
                    deposits: beginCell().endCell(),
                },
                code,
            ),
        );

        // 部署bankMain
        const deployResult = await bankMain.sendDeploy(bankMainDeployer.getSender(), toNano('0.1'));
    });

    it('claim interest', async () => {
        // log(`TTT Main address: ${tttCoinMain.address}`);

        // 1. 先mint 1000000个TTT代币给tttCoinDeployer
        await tttCoinMain.sendMint(
            tttCoinDeployer.getSender(),
            tttCoinDeployer.address,
            toNano('1000000'),
            toNano('0.05'),
            toNano('0.5'),
        );

        // 2. 获取tttCoinDeployer的Jetton钱包地址
        const tttDeployerWalletAddress = await tttCoinMain.getWalletAddress(tttCoinDeployer.address);
        log(`Jetton Wallet Address: ${tttDeployerWalletAddress}`);

        const deployerJettonWallet = blockchain.openContract(JettonWallet.createFromAddress(tttDeployerWalletAddress));

        // 3. 查看tttDeployer的TTT余额
        const tttDeployerData = await deployerJettonWallet.getJettonBalance();

        log(`TTT Deployer balance: ${Number(tttDeployerData) / 1e9} (${tttDeployerData} nano)`);

        // 4. 转50000个TTT给bank contract的钱包地址用于支付利息
        const bankWalletAddress = await tttCoinMain.getWalletAddress(bankMain.address);

        const transferResult = await deployerJettonWallet.sendTransfer(
            tttCoinDeployer.getSender(),
            toNano('10.5'),
            toNano('50000'),
            bankMain.address,
            tttCoinDeployer.address,
            beginCell().endCell(),
            toNano('10'),
            beginCell().endCell(),
        );

        // 5. 验证bankWalle收到了TTT
        const bankJettonWallet = blockchain.openContract(JettonWallet.createFromAddress(bankWalletAddress));
        const bankWalletBalance = await bankJettonWallet.getJettonBalance();
        log(`bankWalletBalance TTT balance: ${Number(bankWalletBalance) / 1e9} (${bankWalletBalance} nano)`);
        expect(bankWalletBalance).toBe(toNano('50000'));

        const time1 = Math.floor(Date.now() / 1000);
        const time2 = time1 + 60;
        blockchain.now = time1;

        await bankMain.sendDeposit(userA_Wallet.getSender(), toNano('2'));
        // 推进区块时间 模拟存储时间
        blockchain.now = time2;
        const depositBefore = await bankMain.getUserDeposit(userA_Wallet.address);

        log(
            `Deposit before claiming interest: ${Number(depositBefore.amount) / 1e9} TON (timestamp: ${depositBefore.timestamp})`,
        );
        log(`Bank Wallet Address: ${bankWalletAddress}`);
        log(`TTT Coin Deployer Address: ${tttCoinMain.address}`);
        log(`Bank Main Address: ${bankMain.address}`);
        log(`User A Wallet Address: ${userA_Wallet.address}`);

        const claimableInterest = await bankMain.getClaimableInterest(userA_Wallet.address);
        console.log(claimableInterest, 'Claimable Interest: ');

        const result = await bankMain.sendClaimInterest(userA_Wallet.getSender(), bankWalletAddress, toNano('1'));
        // console.log(result.transactions, 'Transaction Result: ');

        const userWallet = await tttCoinMain.getWalletAddress(userA_Wallet.address);
        const userJettonWallet = blockchain.openContract(JettonWallet.createFromAddress(userWallet));
        const userBalance = await userJettonWallet.getJettonBalance();
        log(`User TTT balance after claiming interest: ${Number(userBalance) / 1e9} (${userBalance} nano)`);
    });
});
```