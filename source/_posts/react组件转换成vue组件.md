---
title: react组件转换成vue组件(1)
date: 2020-01-09 12:01:43
tags:
  - react
  - vue
top:
categories:
  - javascript
  - npm package
---

今天完成了一个 react 组件的 vue 化--[vue-lazyload-pic](https://github.com/ShowPenZ/vue-lazyload-pic)

顺手重新撸了一把 vue

vue 的模版语法写的我实在蛋疼所以直接上了 jsx 语法，也方便双向绑定
   方法:
   (1): 增加两个插件
    <code>yarn add @vue/babel-helper-vue-jsx-merge-props
    yarn add @vue/babel-preset-jsx</code>

   (2): 在`.babelrc`文件内做如下修改:

   ```json
   {
     "presets": ["@vue/babel-preset-jsx"]
   }
   ```

   就可以快乐的使用 jsx 语法了<br/>

   例子: [vue-lazyload-pic](https://github.com/ShowPenZ/vue-lazyload-pic)

   ```vue
    render() {
        const that = this;
        const { imgLoaded, imgClassName, img, alt, skeleton } = that;
        const onLoad = () => {
            that.$emit('onloads', true);
        };

        return (
            <div class="P-container">
                {imgLoaded ? (
                <img class={ClassNames('defaultImg', imgClassName)} src={img} alt={alt} />
                ) : (
                <div class={ClassNames('skeleton1', skeleton)}></div>
                )}
                <img class="noShow" src={img} alt={alt} onLoad={onLoad} />
            </div>
        );
    },
   ```

   上面代码 有个注意点就是
   <!--more-->
   ```
   <img class="noShow" src={img} alt={alt} onLoad={onLoad} />
   ```

   jsx 内的 img 标签有 onLoad 属性方法 意思就是当图片资源加载完成后会有回调通知所以在这个方法内我们可以使用 Vue 的 this.$emit 来派发一个 onloads 事件通知,在父组件内进行监听
   
   代码例子为如下

   ```vue
   <LazyLoad.PicLazyLoad 
        img={Sevn} // 图片 
        skeleton="newSkeleton"//占位图css样式(className) 
        imgClassName="sevn" // 图片的样式(className)
        alt="sevn" 
        imgLoaded={imgLoaded} 
        {...{ on: { onloads: onLoads }}} //监听图片加载 
   />
   ```
   使用<code>{...{ on: { onloads: onLoads }}}</code>来监听$emit派发的onload事件
   详细代码以及使用方式请参阅[这里](https://github.com/ShowPenZ/vue-lazyload-pic/blob/master/README.md)

   接下来是两个框架对于相同代码逻辑的不同实现对比 
   react版本的
   ``` react
    class PicLazyLoad extends React.Component {
        static propTypes = {
            onLoaded: PropTypes.func.isRequired,
            loaded: PropTypes.bool.isRequired,
            img: PropTypes.string.isRequired,
            alt: PropTypes.string.isRequired,
            imgClassName: PropTypes.string,
            skeleton: PropTypes.string
        };

        static defaultProps = {
            alt: ""
        };

        state = {
            loaded: false
        };

        render() {
            const that = this;
            const { loaded } = that.state;
            const { img, alt, imgClassName, skeleton } = that.props;

            const onLoad = () => {
                that.setState({
                    loaded: true
                });
            };

            return (
                <div className="container">
                    {loaded ? (
                    <img
                        className={ClassNames("defaultImg", imgClassName)}
                        src={img}
                        alt={alt}
                    />
                    ) : (
                    <div className={ClassNames("skeleton1", skeleton)}></div>
                    )}
                    <img className="noShow" src={img} alt={alt} onLoad={onLoad} />
                </div>
            );
        }
    }
   ```

   Vue版本的
   ``` vue
   const PicLazyLoad = {
        name: 'PicLazyLoad',
        props: {
            imgLoaded: {
                type: Boolean,
                required: true,
            },
            img: {
                type: String,
                required: true,
            },
            alt: {
                type: String,
                required: true,
            },
            imgClassName: {
                type: String,
                required: false,
            },
            skeleton: {
                type: String,
                required: false,
            },
        },
        data() {
            return {};
        },
        render() {
            const that = this;
            const { imgLoaded, imgClassName, img, alt, skeleton } = that;
            const onLoad = () => {
                that.$emit('onloads', true);
            };

            return (
                <div class="P-container">
                    {imgLoaded ? (
                    <img class={ClassNames('defaultImg', imgClassName)} src={img} alt={alt} />
                    ) : (
                    <div class={ClassNames('skeleton1', skeleton)}></div>
                    )}
                    <img class="noShow" src={img} alt={alt} onLoad={onLoad} />
                </div>
            );
        },
   };
   ```
   当然简单的组件Vue有了jsx的加持后基本和react没什么太大的差别下一篇带来稍微复杂一点点的另一个组件再次一起感受下两个框架的一些使用上的差别
