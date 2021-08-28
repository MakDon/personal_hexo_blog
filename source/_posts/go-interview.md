---
title: go-interview
date: 2021-08-24 22:53:04
tags:['Go']
author: makdon
categories:
---

### WIP: Go 面试范围整理

换工作之前是不方便公开整理相关资料的，现在新工作入职了一小段时间，应该适合把当时面试 Go 相关的知识范围整理一下了。     
本篇整理的主要是 backend 相关的 Golang 的知识，不包含其它必要的后端知识如 DB，OS 等。  
排行顺序比较流水账，主要是个人笔记，所以以它在个人心中排行程度排序

#### std

这里的 std 指的是 Golang 里面的一些容器的标准实现，例如 Array, Slice, Map 的实现。     
在工作中，Array, Slice, Map 的使用几乎可以说是基础中的基础。    
不过在基础里面还是可以做一点小文章。

##### Array

在实际工作中用得比较少，基本上都是在用 Slice。
在某些场景下面用 Array 可以借助编译器做一些编译时的边界检查。     
不过个人经验感觉还是很少会用到。

##### Slice

Slice 头定义可以参考 reflect.SliceHeader ，由指针, len, cap构成，网上相关文章一搜一大把。
可以留意的是:    

- `_ = append(foo, elem)` 动作对 foo 不是只读的，同理还有一些作为函数参数传递然后在函数内修改值的写法。
- 可以通过 make([]T, 0, num) 为 Slice 预分配长度为 num 的空间，例如把[]T 倒腾成 []T.ID 时，就可以预分配 len([]T)个长度，减少扩容次数。
- []byte 与 string 互转时，可以用 unsafe 包以减少一次内存分配。用法非常简单，通过unsafe.Pointer 转一下就可以了: `s := *(*string)(unsafe.Pointer(&b))`
  有很多性能敏感的场景都用到了这种写法，例如 strings 包内 Builder.String() 方法。需要注意的是，返回 s 之后，原来的 b 就不能再修改了，否则 s 会跟着变动。

##### Map

map 要说的并不多，只需要留意它并发读写就会 panic。可以加个 sync.RWMutex 一起用即可。    
有些并发读写场景更适合适用 sync.Map 以达到更好的性能, 具体适用场景可以参考官方文档，此处不再赘述。

### context

无论是 Web 后端服务还是数据库还是网络库，都离不开 ctx。    
最常见的可以说是 sync.cancelCtx 了，在各大网络库都可以看到使用得特别频繁。同功能的还有 sync.timerCtx 用来做超时等。
其次就是 sync.valueCtx 了，正如 http 里面有 header， grpc 的 metadata 里面也带了不少信息，对应到 Go 里面的具体实现，就是每个 method 参数里面的第一个 context.Context 了。     
需要留意的是，原生 context.Value() 使用的是链式查找，复杂度是 O(n)的，虽然通常来说在实际生产中 value 不算特别多所以还是可以接受的。    
grpc-go 中，定义了一个 metadata.Pairs，它是使用了 map 存储 kv，从而达到 O(1) 的查询效率，只不过从 ctx 里面取 md，还是需要先从头遍历。    
在目前可接触到的代码中，极大部分已经使用 grpc 了，所以 grpc 的 metadata 部分 api 还是需要非常熟悉的。

### sync

#### Mutex && RWMutex

锁 && 读写锁，只要写代码就绕不过去的话题。具体使用场景可以回去看操作系统教材。     
读写锁的实现有点意思，值得一看。    
在这里可以顺便一提的时，可以通过 atomic 包实现很多并发安全的原子性操作，例如 CAS 操作，性能要比锁要好不少。    
甚至可以把一个 int64 切开两半各存一个 int32，这样可以不用锁就完成了两个变量原子性地更新。不记得在标准库具体哪里看到过这种实现了。

#### 其它

sync.WaitGroup, sync.Once, sync.Pool 等等都值得看，看官方文档即可。

#### channel

网上非常多的资料，主要讨论的就是这三方面的内容：
- 有缓存跟无缓存 channel 行为上面的异同
- closed, 正常, nil 三种状态下面，recv 和 send 的行为的响应。
- send/recv 对 goroutine 状态的影响以及如果使用 channel 实现 Goroutine 的调度（例如 cancelCtx 使用 close chan 通知所有 `<-ctx.Done()` 协程, 等）

#### interface && reflect

这里的 interface 主要指 `interface{}`。借助 `interface{}` 可以使用非常动态的运行时类型判断，根据不同类型而采取不同的操作。    
配合 reflect 包，可以用比较啰嗦的语句，达到非常动态的效果。常见于 ORM 框架实现，json 框架实现等等。   
具体使用可以参考标准库 json.Marshal(), json.Unmarshal() 等。

#### GMP



#### GC

#### benchmarking