---
title: react-lazyload-pic
date: 2019-12-09 15:04:57
tags: 
 - react 
 - lazyload-pic
top:
categories: 
 - javascript
 - npm package
---
[English](https://github.com/ShowPenZ/react-lazyload-pic/blob/master/README_en-US.md) | 中文


# react-lazyload-pic

> 图片以及图片列表懒加载的react组件

## Installation

```
$ npm install react-lazyload-pic --save
or
$ yarn add react-lazyload-pic
```

## Usage 
方法1 仅针对当前所要展示的大图做完全加载后展示，未完全加载时图片用占位图替代

![lazyloadlist.gif](https://i.loli.net/2019/12/09/1SF9QoBCuiMOW63.gif)
```javascript
import { LazyLoadPic } from "react-lazyload-pic";
import Sevn from '@/assets/sevn.jpg'

class App extends React.Component {
  state = {
    loaded : false
  }

  render() {
    const that = this;
    const { loaded } = that.state;
    const onLoad = () => {
      that.setState({
        loaded:true
      })
    }
   
    return <div className="container"> 
              <PicLazyLoad
                img={Sevn}             // 图片
                skeleton="newSkeleton" // 占位图css样式(className)
                imgClassName="sevn"    // 图片的样式(className)
                alt="sevn"
                loaded={loaded}
                onLoad={onLoad}
              /> 
            </div>
  }
}

export default App;


//css 
{
  .container {
    display: flex;
    width: 100%;
    height: 100vh;
    font-size: 30px;
  }

  .newSkeleton,
  .sevn {
    width: 200px;
    height: 100px;
  }
}

```
<!--more-->
方法2 懒加载图片列表，当图片加载才会被显示在列表内
![lazyloadlist.gif](https://i.loli.net/2019/12/09/4dNFHoXhxE3jmcy.gif)
```javascript
import { LazyLoadPic } from "react-lazyload-pic";

class App extends React.Component {
  constructor() {
    super();
    this.state = {
      imgArr: []
    };
  }

  componentDidMount() {
    const that = this;
    let arr = [];

    for (let i = 1; i < 17; i++) {
      arr.push({ url: require(`./images/${i}.png`) });
    }

    that.setState({
      imgArr: _.concat(arr)
    });
  }

  render() {
    const that = this;
    const { imgArr } = that.state;

    return (
      <div className="container">
        <LazyLoadPic
          boxClassName="boxContainer"
          imgBoxClassName="imgBoxContainer"
          imgClassName="imgContainer"
          imgArr={imgArr}
        />
      </div>
    );
  }
}

export default App;

```


## Properties

```javascript 
  //方法1
  static propTypes = {
    onLoaded: PropTypes.func.isRequired,
    loaded: PropTypes.bool.isRequired,
    img: PropTypes.string.isRequired,
    alt: PropTypes.string.isRequired,
    imgClassName: PropTypes.string,
    skeleton: PropTypes.string
  };

  static defaultProps = {
    alt: "",
  };

  //方法2
   static propTypes = {
    imgClassName: PropTypes.string,
    imgBoxClassName: PropTypes.string,
    alt: PropTypes.string
  };

  static defaultProps = {
    alt: ""
  };
```

# License

MIT
