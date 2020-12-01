---
title: 'umi中使用yield call 执行promise函数'
date: 2019-09-17 12:00:31
tags: 
  - dva
  - react 
  - umi.js 
top:
categories: javascript
---

```javascript
//invoke 为一个promise 函数
export function get_account_auth(authKey) {
  const arg = { authKey };

  return invoke("account_auth", arg)
    .then(resp => resp.data.token)
    .catch(onError);
}
 ======
effects: {
    *getAuthKey({ payload }, { call, put, race, select, take }) {
      const resp = yield call(IndexApi.getAuthKey, {});
      
      //call(fn,...arg)
      const token = yield call(Get_account_auth, resp.data.authKey);

      yield put(StateAt.index({ authKey: resp.data.authKey, token }));
    },
},
```

# 下面 dva 的典型 model 例子

```javascript
app.model({
  namespace: "todo",
  state: [],
  reducers: {
    add(state, { payload: todo }) {
      // 保存数据到 state
      return [...state, todo];
    }
  },
  effects: {
    *save({ payload: todo }, { put, call }) {
      // 调用 saveTodoToServer，成功后触发 `add` action 保存到 state
      yield call(saveTodoToServer, todo);
      yield put({ type: "add", payload: todo });
    }
  },
  subscriptions: {
    setup({ history, dispatch }) {
      // 监听 history 变化，当进入 `/` 时触发 `load` action
      return history.listen(({ pathname }) => {
        if (pathname === "/") {
          dispatch({ type: "load" });
        }
      });
    }
  }
});
```
