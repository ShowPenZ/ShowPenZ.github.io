---
title: TON 合约开发个人经历(3)
date: 2025-04-10 17:16:36
tags: Ton Func
categories: Ton 合约开发
---
# TON 智能合约开发经验分享

## 合约部分

注意：func 中注释使用 ;;

### 首先

1. 定义的变量统一放顶部便于查阅和管理
2. load_data()和save_data()成对出现而且需要严格对应

```lua
+-------------------+
| TVM 寄存器堆栈     |
+-------------------+
| C0: 执行代码       |
| C1: 参数           |
| C2: 返回地址       |
| C3: 上下文         |
| C4: 合约数据 🟡     | ← load_data() 从这里读
|                   | ← save_data(x) 会替换这里
| C5: 合约地址       |
| C6: 合约余额       |
| C7: 区块时间戳     |
| C8: 随机值         |
| C9: 消息体         |
| C10: 消息头        |
+-------------------+
```
<!--more-->
3. recv_internal 在这里面进行标准的消息解析过程 解析传入的消息
   - 外部消息为存钱5,取钱6,领取利息7
   - 构建存，取以及领取利息的信息字典(存款人地址，时间，金额)

## 构建消息体

消息体的概念非常重要([文档地址](https://docs.ton.org/mandarin/v3/documentation/smart-contracts/message-management/sending-messages))

在 TON 合约中，想让合约"给别人转账"，你必须构造一条内部消息，而构造这条消息的函数就是 build_transfer_msg()。
因为取钱和存钱的消息不需要携带任何信息(当然你想携带信息也是可以的)

### 基本转账消息构建

```c
(cell) build_transfer_msg(slice to, int amount) inline {
    return begin_cell()
        .store_uint(const::msg::normal, 6) ;;0x18
        .store_slice(to)
        .store_coins(amount)
        .store_uint(0, 1 + 4 + 4 + 64 + 32 + 1 + 1) ;; 没有携带消息体所以设置为0
        .end_cell();
}
```

### 消息标志位说明

```c
.store_uint(0x18,6) 拆分位以下结构

.store_uint(0, 1) ;; 告知ton这一个内部消息 
.store_uint(1, 1) ;; 禁用超立方路由(基本不用改变这个)
.store_uint(1, 1) ;; 是否回弹消息
.store_uint(0, 1) ;; 该消息本身是否是 bounce 消息
.store_unit(0, 1) ;; 是否有source字段
.store_unit(0, 1) ;; 是否有destination字段
source和destination这两个不填写可以看作 .store_unit(0,2)
即二进制 011000 = 0x18(16进制) = 24(10进制)
```

### 消息体字段说明

```c
.store_uint(0, 1 + 4 + 4 + 64 + 32 + 1 + 1) 解释为

.store_dict(extra_currencies) ;;额外的currency 1位
.store_coins(0) ;; ihr_fee 超立方路由fee 4位
.store_coins(fwd_value) ;; fwd_fee foward fee 4位
.store_uint(cur_lt(), 64) ;; 逻辑时间戳 64位
.store_uint(now(), 32) ;; 消息或交易的 发送unix时间 32位
.store_uint(0,  1) ;; 是否包含 Init 部分 1位
.store_uint(0,  1) ;; 标记消息体（message body）的存储方式 1位
```

### TTT 代币转账消息构建

第二种转账的币不为 TON，例如合约中的 TTT - 领取利息时通知银行合约将利息(TTT)转给用户

```c
(cell) build_ttt_transfer_msg(slice to, int amount, slice bank_wallet_address) inline {
    ;; Build the message body first
    cell msg_body = begin_cell()
        .store_uint(0xf8a7ea5, 32)        ;; op::transfer
        .store_uint(0, 64)                ;; query_id
        .store_coins(amount)              ;; amount
        .store_slice(to)                  ;; destination
        .store_slice(to)        ;; response_destination
        .store_uint(0, 1)                 ;; no_payload
        .store_coins(10000000)           ;; forward_ton_amount
        .store_uint(0, 1)                 ;; no_forward_payload
        .end_cell();

    ;; Build the complete message
    return begin_cell()
        .store_uint(0x18, 6)              ;; message flags (0b011000)
        .store_slice(bank_wallet_address) ;; destination address
        .store_coins(50000000)              ;; 手续费 Toncoin > to_nano(TTT) + forward_ton_amount 即amout 要大于 ttt的amount + fwd_amount
        .store_uint(1, 1 + 4 + 4 + 64 + 32 + 1 + 1)  ;; message headers  这里要设置成1 因为这里重写了msg_body 
        .store_ref(msg_body)              ;; message body as a reference
        .end_cell();
}
```

## 全部合约代码

```c
#include "imports/stdlib.fc";

const const::min_tons_for_storage = 10000000; ;; 0.01 TON for storage
const const::min_tons_for_gas = 50000000;    ;; 0.05 TON for gas fees
const const::op::increment = 4;    ;; 操作码：增加计数器
const const::op::receive = 5;      ;; 操作码：接收资金
const const::op::withdraw = 6;     ;; 操作码：提取资金
const const::op::init = 0;         ;; 操作码：初始化
const const::op::claim_interest = 7; ;; 操作码：领取利息
const const::err::invalid_init = 100; ;; 错误码：无效初始化
const const::err::not_initialized = 102; ;; 错误码：未初始化
const const::err::not_owner = 103; ;; 错误码：非所有者操作
const const::err::insufficient_balance = 104;  ;; 错误码：余额不足
const const::err::insufficient_user_balance = 105;  ;; 错误码：用户余额不足
const const::err::invalid_op = 777;           ;; 错误码：无效操作码
const const::msg::normal = 0x18;    ;; 标准内部消息标志 (0b011000)
const const::op::check_deposit = 101;    ;; 检查存款是否有效
const const::interest_period = 30;      ;; 每30秒计算一次利息
const const::interest_rate = 1;         ;; 利率1%
const int workchain = 0; ;; 工作链ID

(int, slice, cell) load_data() inline {
    ;; - 当合约首次部署时，get_data() 会返回部署时设置的初始化数据
    ;; 这些初始值必须按照 load_data() 方法定义的格式提供
    var ds = get_data().begin_parse();  ;; 获取合约存储的数据并开始解析
    return (
        ds~load_uint(32),      ;; 1. total_deposits: 总存款金额（可选，用于统计）
        ds~load_msg_addr(),    ;; 2. owner_address: 合约所有者地址
        ds~load_ref()         ;; 3. deposits: 存款字典（cell 类型）
    );
}
;; impure 表示这个函数会修改合约的存储状态 就是告知编译器这个函数会产生副作用
;; inline 表示这个函数会被内联编译，提高执行效率简单说就是把函数展开到使用的地方
;; inline 适用于小型、频繁调用的函数，
;; 如 load_data() 和 save_data()。
;; 避免对大函数使用 inline，以免代码膨胀、增加合约大小 要避免滥用。

;; save_data 和 load_data 的数据格式必须严格对应，这是 TON 智能合约中的一个重要原则。
() save_data(int total_deposits, slice owner_address, cell deposits) impure inline {
    set_data(begin_cell()
        .store_uint(total_deposits, 32)     ;; 1. total_deposits: 总存款金额
        .store_slice(owner_address)        ;; 2. owner_address: 合约所有者地址
        .store_ref(deposits)               ;; 3. deposits: 存款字典
        .end_cell());   
}

;; 解析存款
(int, int, int, int) parse_deposit(slice data) inline {
    return (
        data~load_coins(),     ;; amount: 存款金额
        data~load_uint(32),    ;; timestamp: 存款时间
        data~load_uint(32),    ;; last_claim_time: 上次领取时间
        data~load_coins()      ;; accumulated_interest: 累计利息
    );
}

(slice, int) get_dict(slice key, cell dict) inline {
    if (dict.null?()) {
        return (null(), 0);
    }
    
    ;; 将 slice 类型的 key 转换为整数哈希值
    int key_hash = slice_hash(key);
    var (value, success) = udict_get?(dict, 256, key_hash);

    if (success == 0) {  ;; 如果 success 为 0，表示没找到键
        return (null(), 0);
    }
    
    return (value, -1);
}

(cell) set_dict(slice key, slice value, cell dict) inline {
    ;; 如果字典为空，创建一个新的字典
    if (dict.null?()) {
        dict = new_dict();
    }
    
    ;; 将 slice 类型的 key 转换为整数哈希值
    int key_hash = slice_hash(key);
    
    ;; 检查 value 是否为有效的 slice
    if (value.null?()) {
        return dict;  ;; 如果 value 无效，返回原始字典
    }
    
    ;; 检查 value 是否还有剩余数据
    if (slice_bits(value) == 0) {
        ~strdump("Error: value is empty");
        return dict;  ;; 如果 value 为空，返回原始字典
    }
    ;; 使用 udict_set 替代 idict_set，因为它处理非负整数键
    cell result = udict_set(dict, 256, key_hash, value);
    
    if (result.null?()) {
        return dict;
    }
    
    return result;
}

;; 构建 TON 转账消息
(cell) build_transfer_msg(slice to, int amount) inline {
    return begin_cell()
        .store_uint(const::msg::normal, 6)
        .store_slice(to)
        .store_coins(amount)
        .store_uint(0, 1 + 4 + 4 + 64 + 32 + 1 + 1) ;; 没有携带消息体所以设置为0
        .end_cell();
}

;; 构建 "ttt" 转账消息
(cell) build_ttt_transfer_msg(slice to, int amount, slice bank_wallet_address) inline {
    ;; Build the message body first
    cell msg_body = begin_cell()
        .store_uint(0xf8a7ea5, 32)        ;; op::transfer
        .store_uint(0, 64)                ;; query_id
        .store_coins(amount)              ;; amount
        .store_slice(to)                  ;; destination
        .store_slice(to)        ;; response_destination
        .store_uint(0, 1)                 ;; no_payload
        .store_coins(10000000)           ;; forward_ton_amount
        .store_uint(0, 1)                 ;; no_forward_payload
        .end_cell();

    ;; Build the complete message
    return begin_cell()
        .store_uint(0x18, 6)              ;; message flags (0b011000)
        .store_slice(bank_wallet_address) ;; destination address
        .store_coins(50000000)              ;; 手续费 Toncoin > to_nano(TTT) + forward_ton_amount 即amout 要大于 ttt的amount + fwd_amount
        .store_uint(1, 1 + 4 + 4 + 64 + 32 + 1 + 1)  ;; message headers  这里要设置成1 因为这里重写了msg_body 
        .store_ref(msg_body)              ;; message body as a reference
        .end_cell();
}



() recv_internal(int msg_value, cell in_msg, slice in_msg_body) impure {
    ;; 标准的消息解析过程 解析传入的消息
    slice cs = in_msg.begin_parse();
    ;; 标准的消息解析过程 这里定义但是没有使用
    int flags = cs~load_uint(4);
    ;; TON 消息头部的标准格式：
    ;; 前 4 位是消息标志（flags）
 
    slice sender_address = cs~load_msg_addr();
   
    ;; 如果消息体小于 32 位，则直接返回
    if (slice_bits(in_msg_body) < 32) {  
        return();  
    }
    var (total_deposits, owner_address, deposits) = load_data();
   

    ;; 检查合约是否已初始化
    ;; throw_unless(102, owner_address.null?()); ;; 错误码 102 表示未初始化
    ;; 从消息体中读取操作码 使用 32 位操作码是一个常见的约定，但不是强制要求 提供了强大的灵活性
    int op = in_msg_body~load_uint(32);

    ;; 它利用了 TON 智能合约的默认行为，不需要编写特殊的处理代码。
    ;; 只要合约执行成功，资金就会被接受。
    ;; 如果操作码为 5，则直接返回，接受转入的资金
    if (op == const::op::receive) {
        ;; 检查存款是否有效
        ;; throw_unless(const::op::check_deposit, msg_value > const::min_tons_for_storage);
        ;; 确保我们有一个有效的字典
       
        ;; 检查是否是空的 cell
        slice deposits_slice = deposits.begin_parse();
        if (slice_bits(deposits_slice) == 0) {
            deposits = new_dict();
        }
                
        var (deposit_data, success) = get_dict(sender_address, deposits);
        
        slice deposit_slice = deposit_data; ;; 显式声明 deposit_data 为 slice
        ;; 如果存款数据为空，则设置为0
        var (amount, timestamp, last_claim_time, accumulated_interest) = deposit_data.null?() 
            ? (0, 0, 0, 0) 
            : parse_deposit(deposit_slice);

        ;; 更新存款金额
        int new_amount = amount + msg_value;
        ;; 更新存款时间戳
        int new_timestamp = now();
        ;; 如果是首次存款，设置上次领取时间为当前时间
        int new_last_claim_time = last_claim_time ? last_claim_time : new_timestamp;
        ;; 如果不是首次存款，计算累积的利息
        if (amount > 0) {
            ;; 计算从上次计息时间到现在的完整周期数
            int time_diff = new_timestamp - last_claim_time;
            int complete_periods = time_diff / const::interest_period;
            
            if (complete_periods > 0) {
                ;; 计算新增利息 (amount * periods * rate)
                int new_interest = (amount * complete_periods * const::interest_rate) / 100;
                accumulated_interest += new_interest;
            }
        }
        ;; 创建存款数据
        slice deposit_value = begin_cell()
            .store_coins(new_amount)
            .store_uint(new_timestamp, 32)
            .store_uint(new_timestamp, 32)  ;; 重置计息时间
            .store_coins(accumulated_interest)
            .end_cell().begin_parse();

        deposits = set_dict(sender_address, deposit_value, deposits);
        ;; 更新存款数据
        save_data(total_deposits + msg_value, owner_address, deposits);
        return();   
    }

    ;; 如果操作码为 6 则执行提款操作
    if (op == const::op::withdraw) {
        ;; 从消息体读取提款金额
        int withdraw_amount = in_msg_body~load_coins();
      
        ;; 获取用户存款记录
        var (user_deposit_data, success) = get_dict(sender_address, deposits);
    
        ;; 检查用户是否有存款记录
        throw_unless(const::err::not_owner, success);
        
        ;; 解析存款数据
        var (amount, timestamp, last_claim_time, accumulated_interest) = parse_deposit(user_deposit_data);
        throw_unless(const::err::insufficient_user_balance, amount >= withdraw_amount);

        ;; 检查合约的当前余额
        var [balance, _] = get_balance();

        ;; 检查合约余额是否足够
        throw_unless(const::err::insufficient_balance, balance >= withdraw_amount + const::min_tons_for_storage);

        ;; 计算当前时刻的累积利息
        int current_time = now();
        int time_diff = current_time - last_claim_time;
        int complete_periods = time_diff / const::interest_period;
        
        if (complete_periods > 0) {
            ;; 计算新增利息
            int new_interest = (amount * complete_periods * const::interest_rate) / 100;
            accumulated_interest += new_interest;
        }

        ;; 取款后更新存款记录
        int new_amount = amount - withdraw_amount;
   
        ;; 更新存款记录
        slice deposit_value = begin_cell()
            .store_coins(new_amount)
            .store_uint(timestamp, 32)
            .store_uint(current_time, 32)
            .store_coins(accumulated_interest)
            .end_cell().begin_parse();

        deposits = set_dict(sender_address, deposit_value, deposits);

        ;; 更新总存款
        save_data(total_deposits - withdraw_amount, owner_address, deposits);

        ;; 发送 TON
        int msg_mode = 1; ;; 单独支付手续费
        send_raw_message(build_transfer_msg(sender_address, withdraw_amount), msg_mode);
        ~strdump("Withdrawal completed successfully");

        return();
    }

    ;; 如果操作码为 7 则执行领取利息操作
    if (op == const::op::claim_interest) {
        slice bank_wallet_address = in_msg_body~load_msg_addr();
        ;; 获取用户存款记录
        var (deposit_data, success) = get_dict(sender_address, deposits);
        ;; 非存款人无法领取利息
        throw_unless(const::err::not_owner, success);
        
        ;; 解析存款数据
        var (amount, timestamp, last_claim_time, accumulated_interest) = parse_deposit(deposit_data);
        
        ;; 计算当前时刻的累积利息
        int current_time = now();
        int time_diff = current_time - last_claim_time;
        int complete_periods = time_diff / const::interest_period;
        
        if (complete_periods > 0) {
            ;; 计算新增利息
            int new_interest = (amount * complete_periods * const::interest_rate) / 100;
            accumulated_interest += new_interest;
        }
        
        ;; 如果有累积的利息可以领取
        if (accumulated_interest > 0) {
            ;; 发送TTT利息
            int msg_mode = 1;
            send_raw_message(build_ttt_transfer_msg(sender_address, accumulated_interest, bank_wallet_address), msg_mode);
            
            ;; 重置累积利息和计息时间
            deposits = set_dict(sender_address, begin_cell()
                .store_coins(amount)
                .store_uint(timestamp, 32)
                .store_uint(current_time, 32)
                .store_coins(0) ;; 重置累积利息
                .end_cell().begin_parse(), deposits);
            save_data(total_deposits, owner_address, deposits);
        }
        
        return();
    }

    ;; 如果操作码不匹配，则抛出自定义错误
    throw(const::err::invalid_op);
}


;; 比较两个 slice 是否相等的辅助函数
int equal_slices (slice s1, slice s2) inline {
    return slice_hash(s1) == slice_hash(s2);
}


;; 获取合约存储数据
(int, slice, cell) get_contract_storage_data() method_id {
    ~strdump("get_contract_storage_data");

    var (total_deposits, owner_address, deposits) = load_data();
    return (total_deposits, owner_address, deposits);
}

;; 获取某个用户存款
(int, int) get_user_deposit(slice user_addr) method_id {
    var (_, _, deposits) = load_data();
    var (deposit_data, success) = get_dict(user_addr, deposits); ;; 解构 (slice, int)
    if (deposit_data.null?()) {
        return (0, 0);
    }
    var (amount, timestamp, _, _) = parse_deposit(deposit_data); ;; 只取 amount 和 timestamp
    return (amount, timestamp);
}

;; 获取用户累积的利息
(int) get_user_interest(slice user_addr) method_id {
    var (_, _, deposits) = load_data();
    var (deposit_data, success) = get_dict(user_addr, deposits); ;; 解构 (slice, int)
    
    ;; 如果用户没有存款记录，返回0
    if (deposit_data.null?()) {
        return 0;
    }
    
    ;; 解析存款数据
    var (amount, timestamp, last_claim_time, accumulated_interest) = parse_deposit(deposit_data);
    
    ;; 计算当前时刻的新增利息
    int current_time = now();
    int time_diff = current_time - last_claim_time;
    int complete_periods = time_diff / const::interest_period;
    
    ;; 如果有新的完整周期，计算新增利息
    if (complete_periods > 0) {
        ;; 计算新增利息 (amount * periods * rate)
        int new_interest = (amount * complete_periods * const::interest_rate) / 100;
        accumulated_interest += new_interest;
    }
    
    return accumulated_interest;
}

;; 获取用户可领取的利息（包括当前时间段的计算）
(int, int) get_claimable_interest(slice user_addr) method_id {
    var (_, _, deposits) = load_data();
    var (deposit_data, success) = get_dict(user_addr, deposits); ;; 解构 (slice, int)
    
    ;; 如果用户没有存款记录，返回(0, 0)
    if (deposit_data.null?()) {
        return (0, 0);
    }
    
    ;; 解析存款数据
    var (amount, timestamp, last_claim_time, accumulated_interest) = parse_deposit(deposit_data);
    
    ;; 计算当前时刻的新增利息
    int current_time = now();
    int time_diff = current_time - last_claim_time;
    int complete_periods = time_diff / const::interest_period;
    
    ;; 计算新增利息
    int new_interest = 0;
    if (complete_periods > 0) {
        new_interest = (amount * complete_periods * const::interest_rate) / 100;
        accumulated_interest += new_interest;
    }

    ;; 返回(累积利息, 新增利息)
    return (accumulated_interest, new_interest);
}

int balance() method_id {
    ;; get_balance() 是一个内置函数，用于获取合约的余额
    ;; 返回一个包含两个元素的元组：
    ;; 第一个元素是合约的余额（balance）
    ;; 第二个值是额外数据（通常不使用，用 _ 忽略）
    var [balance, _] = get_balance();
    return balance;
}
```