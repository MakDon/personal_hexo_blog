---
title: 'Golang: 一个 map 里面有多个相同的 key？'
tags: []
id: '208'
author: makdon
categories:
  - - 数据结构与算法
date: 2021-04-07 23:03:30
---

最近在 v2ex 看到这篇[有趣的帖子](https://v2ex.com/t/768320)，里面的问题很有意思，用来水篇博客再合适不过了

## The Problem

楼主使用 fiber 这个 web 框架，每次接受请求时从url 解析一个 `id` 参数，然后对一个全局的 counter 进行累加操作。这个全局的 counter 是一个 map\[string\]int。锁什么的都用得很正确，但是神奇的是，println 时发现，map 里面有许多个相同的 key。这与 map 的特性相悖，一个 map 里面 key 应该是唯一的。  
在最后我通过一个 demo 复现了这个 case。具体的代码在下面再一步一步解释。 ![](/img/2021/04/tmp.png)

## 初步定位

原帖在第三次 append 时，给出了一个可以复现的示例代码。  
首先把原帖的代码贴上来:

```
package main

import (
    "fmt"
    "sync"
    "time"

    "github.com/gofiber/fiber/v2"
)

type Counter struct {
    sync.RWMutex
    data map[string]int
}

func (c *Counter) Incr(key string) int {
    c.Lock()
    c.data[key]++
    count := c.data[key]
    c.Unlock()
    return count
}

var (
    accessLog = &Counter{data: make(map[string]int)}
)

func init() {
    go func() {
        ticker := time.NewTicker(time.Second * 10)
        for range ticker.C {
            func() {
                accessLog.Lock()
                fmt.Println(accessLog.data)
                accessLog.data = make(map[string]int)
                accessLog.Unlock()
            }()

        }
    }()

}
func handler(c *fiber.Ctx) error {
    id := c.Params("id")
    accessLog.Incr(id)
    return c.Status(200).SendString("")
}

func main() {
    app := fiber.New(fiber.Config{Prefork: false})
    app.Get("/item/:id", handler)
    app.Listen(fmt.Sprintf(":%d", 8099))
}
```

复制运行后发现的确如此，key 都是重复的。  
首先代码 review 后，没有发现明显问题。锁的使用中规中矩； map 并发写的话，也不应该出现这种情况，而是会直接 panic。所以初步排除了是锁的问题。

## 分而治之

原始代码只包含了两个部分: Counter 和 fiber handler。  
首先把 Counter 拆出来，单独起多个协程对其 incr，无法复现那个 case。具体代码就不细讲了。 那问题应该出在 fiber 的使用上面了。

通过代码 review，想来想去最有鬼的应该就是 key 有问题了。 做了几个猜想:

1.  key 里面长度不一且含有不可见字符: 通过 unsfae 包拿到字符串的 Data地址和 len，可以看到 key 的 len 全部都是 3. 示例代码参考`strHeader := (*reflect.StringHeader)(unsafe.Pointer(&str))`。可以看到 strHeader 的 Len 都是 3。
2.  参考 [The Go Memory Model](https://golang.org/ref/mem)，假设框架用法有误，导致了 key 的使用比 key 从 url 中解析要早，这样可以解释为什么插入 map 的时候 hashkey 都不一致；插入后，若是使用 unsafe 包再解析出来 key，就会使 map 里面都是"id1" 的 key。不过通过对比 fiber 文档、打断点，打日志等方式，否定了这个猜想。

不过 2 的思路已经很接近了，就是“key的内容会变”的这个假设。

## 谜底

如果说一个 string 会变，最可能的原因是它底层的 \[\]byte 变了；在这个 web 框架的场景中， \[\]byte pool 来复用 \[\]byte 又是很常见的思路。 如果插入前 key 没有变化，那么应该就是插入完之后，key 变了。 通过 review 代码，可以看到 fiber 使用了两个 getStr(\[\]byte)string 方法，其中一个直接使用 unsafe 包，而另一个使用string(\[\]byte)。前者不会进行一次内存分配，而是直接把 \[\]byte 作为 string 往外丢，如果底层的 \[\]byte 变更了，那对应 string 的内容也会跟着变更。fiber 的默认设置使用前者作为 getStr 方法。 结合多个现象:

1.  key 大概率会变更而不是一个 immutable string
2.  web 框架常见的 \[\]byte 复用
3.  fiber 默认使用 unsafe 作为 getStr 的实现方法

猜想：我们的 key，在请求完成后，\[\]byte 被重复利用了 假设我们一开始插入了一个 `id1`, 在请求完成后，\[\]byte 被回收利用成了 `id2` map 的实现里面没有拷贝一次 string，所以 map 里面的 key 变成了 id2，但是 hash 还是之前 id1 的 hash 然后分两种情况:

*   新插入 id1，!t.key.equal(key, k), 所以给它分配了一个新的桶
*   新插入 id2，原有的 id2 跟新的 id2 hash 不相等，不会覆盖，还是给它新分配一个新的桶 这种情况下，map 里面出现重复的 key，就解释得通了。

## 复现

既然复现条件搞清楚了，那么这个函数就很好写了,只需要用 unsafe 生成 key，然后在插入之后去修改 key 就可以了。  
在 Golang 中，string promised immutable，而这里使用 unsafe 突破了这个约束，自然就会出现问题。  
用这段代码生成的 map，里面包含了 200个 "id1" 的 key

```
func makeMap()map[string]int {
    m := make(map[string]int)
    for i := 0; i < 200; i++{
        b := []byte("id2")
        str := *(*string)(unsafe.Pointer(&b))
        strptr := (*reflect.StringHeader)(unsafe.Pointer(&str))
        _ = strptr
        m[str]++
        b[2] = '1'
    }
    return m
}
```

## 修复

既然知道了是 key 的问题，就很简单了，以下任意一个解法都可以：

1.  使用`fiber.Config{Prefork: false, Immutable: false}`，这样会保证 \[\]byte 到 string 的时候经过一次内存分配和拷贝，key 在请求完成后也不会变化。缺点是可能带来很多额外的内存分配和拷贝的性能消耗。
2.  使用 `key2 = key +"字符"`， 显式地重新为 key 分配另一块内存，这样也可以保证插入 map 后，key 不会发生变化。原帖有回复提到`accessLog.Incr(id + "")`这样也会解决问题，但是我尝试了`str2 := str + ""`后发现 Data 指针并没有变化，并没有分配新的内存，可能因为不同版本编译器的优化不一样。 解法都是让插入 map 后的 key 不发生变化。

## 后记

在原帖中，因为这个问题一开始并不显然，所以引起了很多讨论，涉及不限于锁、管道、concurrent-map等讨论，最后发现根本不是并发引起的问题不过这些讨论里面提到的一些思路和想法还是值得思考的。其中9楼提出仨优化方案没一个对的，被众人指出，看得我乐呵得 在 v2 也算是比较少见这种讨论得氛围了。