---
title: 'go-interview'
date: 2021-08-24 22:53:04
tags: ['Go']
author: makdon
---

# Go 面试范围整理

换工作之前是不方便公开整理相关资料的，现在新工作入职了一小段时间，应该适合把当时面试 Go 相关的知识范围整理一下了。     
本篇整理的主要是 backend 相关的 Golang 的知识，不包含其它必要的后端知识如 DB，OS 等。  
排行顺序比较流水账，主要是个人笔记，所以以它在个人心中排行程度排序

## containers

这里的 containers 指的是 Golang 里面的一些容器的标准实现，例如 Array, Slice, Map 的实现。     
在工作中，Array, Slice, Map 的使用几乎可以说是基础中的基础。    

#### Array

在实际工作中用得比较少，基本上都是在用 Slice。
在某些场景下面用 Array 可以借助编译器做一些编译时的边界检查。     
不过个人经验感觉还是很少会用到。

#### Slice

Slice 头定义可以参考 reflect.SliceHeader ，由指针, len, cap构成，网上相关文章一搜一大把。
可以留意的是:    

- `_ = append(foo, elem)` 动作对 foo 不是只读的，同理还有一些作为函数参数传递然后在函数内修改值的写法。
- 可以通过 make([]T, 0, num) 为 Slice 预分配长度为 num 的空间，例如把[]T 倒腾成 []T.ID 时，就可以预分配 len([]T)个长度，减少扩容次数。
- []byte 与 string 互转时，可以用 unsafe 包以减少一次内存分配。用法非常简单，通过unsafe.Pointer 转一下就可以了: `s := *(*string)(unsafe.Pointer(&b))`
  有很多性能敏感的场景都用到了这种写法，例如 strings 包内 Builder.String() 方法。需要注意的是，返回 s 之后，原来的 b 就不能再修改了，否则 s 会跟着变动。

#### Map

map 要说的并不多，只需要留意它并发读写就会 panic。可以加个 sync.RWMutex 一起用即可。    
有些并发读写场景更适合适用 sync.Map 以达到更好的性能, 具体适用场景可以参考官方文档，此处不再赘述。

### Libraries

#### context

无论是 Web 后端服务还是数据库还是网络库，都离不开 ctx。    
最常见的可以说是 sync.cancelCtx 了，在各大网络库都可以看到使用得特别频繁。同功能的还有 sync.timerCtx 用来做超时等。
其次就是 sync.valueCtx 了，正如 http 里面有 header， grpc 的 metadata 里面也带了不少信息，对应到 Go 里面的具体实现，就是每个 method 参数里面的第一个 context.Context 了。     
需要留意的是，原生 context.Value() 使用的是链式查找，复杂度是 O(n)的，虽然通常来说在实际生产中 value 不算特别多所以还是可以接受的。    
grpc-go 中，定义了一个 metadata.Pairs，它是使用了 map 存储 kv，从而达到 O(1) 的查询效率，只不过从 ctx 里面取 md，还是需要先从头遍历。    
在目前可接触到的代码中，极大部分已经使用 grpc 了，所以 grpc 的 metadata 部分 api 还是需要非常熟悉的。

#### sync

##### Mutex && RWMutex

锁 && 读写锁，只要写代码就绕不过去的话题。具体使用场景可以回去看操作系统教材。     
读写锁的实现有点意思，值得一看。    
在这里可以顺便一提的时，可以通过 atomic 包实现很多并发安全的原子性操作，例如 CAS 操作，性能要比锁要好不少。    
甚至可以把一个 int64 切开两半各存一个 int32，这样可以不用锁就完成了两个变量原子性地更新。不记得在标准库具体哪里看到过这种实现了。

##### sync 的其它包

sync.WaitGroup, sync.Once, sync.Pool 等等都值得看，看官方文档即可。

### channel

严格来说 channel 也属于 container，同样可以取 len 和 cap。但是由于其为并发设计，所以通常不会把人认为是常规 container 对待。

网上非常多的资料，主要讨论的就是这三方面的内容：
- 有缓存跟无缓存 channel 行为上面的异同
- closed, 正常, nil 三种状态下面，recv 和 send 的行为的响应。
- send/recv 对 goroutine 状态的影响以及如果使用 channel 实现 Goroutine 的调度（例如 cancelCtx 使用 close chan 通知所有 `<-ctx.Done()` 协程, 等）

### interface && reflect

这里的 interface 主要指 `interface{}`。借助 `interface{}` 可以使用非常动态的运行时类型判断，根据不同类型而采取不同的操作。    
配合 reflect 包，可以用比较啰嗦的语句，达到非常动态的效果。常见于 ORM 框架实现，json 框架实现等等。   
具体使用可以参考标准库 json.Marshal(), json.Unmarshal() 等。

### Goroutine && GMP

只要用 Go 就避不开的问题。同样网上有非常多的资料，个人比较推荐的是[这个视频][GMP-u2b], 2018 年的 GopherCon 上面的演讲。

#### GC

大约就是三色标记法的几个步骤，和 write boundary 的实现。    
可以对比着其它 GC 算法看，例如 Hotspot 的[分代回收][hotspot]，Python 的 [reference count][python GC]

#### benchmarking

benchmarking 个人觉得可以分为两部分:
- go test 模块中的 benchmark 选项，评估特定的函数的性能。更适合分析特定函数/代码片段，在写框架/库的时候会用到，更偏向于对比优化前后性能。
- pprof，更适用于实际项目中，在测试环境中进行性能分析和评估的工具，个人感觉更适用于链路较长/较复杂的项目中，且更偏向于分析和定位。

### 极端的性能优化

#### 内存对齐

适当的利用内存对齐的特性可以提高存储性能，减少空间占用。
如 Go 的 [map 实现][padding]里面，key + key + ... + key + value + ... + value 的存储方式，就是为了减少内存对齐而额外使用的空间。

#### boundary check

在每次通过下标访问 array/slice 里面的元素的时候，会进行一次边界检查，如果越界即抛出 panic。
通过提前检查，可以避免一些不必要的边界检查值，例如 binary 库的 [Uint64(b []byte)的实现][boundary check]

#### escape analysis

逃逸分析机制会分析一个变量是否需要逃逸到堆中，典型的场景有:
- 变量太大
- 返回(`return`)了该对象的指针，即栈帧被回收后还需要用到该对象。
- 不确定的分配次数，例如在 for 里面循环 make([]T, 0, 8)

若大量的变量被分配到了堆中，会增大 GC 的压力（因为遍历的节点多了），同时 heap 分配对象也需要额外的计算（运行时动态分配内存而非编译期分配在栈上）    
因此在极端的性能优化中，会尽量避免无意义地让对象分配到 heap 中。

相关的资料也很多，此处不做推荐。

#### 分支预测与位运算

分支预测本应是 CPU 的范畴，不过说到性能优化那讨论到也未尝不可。    
简单来说，由于 CPU 流水线机制，遇到分支操作时（即if else 等对应 jmp 指令），会先采用其中一条分支，在分支条件计算出来后，若使用的分支不对，再进行 rollback。    
当分支预测错误时，会浪费较多的指令执行的机会，因此我们可以尽量避免分支预测错误带来的性能损失：     
- 尽量让所有结果走其中一个分支。    
  有些分支预测的实现是采用上一次的分支走向，当使用此种预测策略时，如果我们代码大部分命中同一个分支，则可以避免大量预测错误带来的性能耗损。
- 把 if else 语句改为位运算：使用位运算即不需要 jmp 指令了。
  例如我们有个 counter，如果 foo 的值等于 1，就进行 + 1 的操作，一般可以写成:
```go
if (foo == 1){
	counter += 1
}
```
使用位运算改写的话，可以写成 `counter += foo & 1`，这样就不需要进行分支操作了。有些简单的运算编译器也足够聪明地优化成位运算而无需手工重写。

例如[simdjson][simdjson]这个库，就使用了大量位运算来解析 json，达到了非常夸张的性能。可以参考[这个演讲][simdjson-infoQ]

#### P 绑定的本地资源

当访问公共变量等资源时，我们就需要先加个锁。但是这些资源有多份，我们就可以考虑先拿本地的，如果本地取不到，再取全局的。    
sync.Pool 里面有[这种设计][p-local]。

#### inline

Go 编译器会在编译期自动把适合条件的函数 inline 到调用函数中，以减少函数调用返回时参数传递入栈出栈等性能耗损。    
当被调用的函数很长时，可以进行拆分，以使部分比较常命中的逻辑分支 inline 到调用函数中。具体可以参考 sync.Once 里面的[这种写法][inline]


[GMP-u2b]: https://www.youtube.com/watch?v=YHRO5WQGh0k
[hotspot]: https://docs.oracle.com/javase/9/gctuning/garbage-collector-implementation.htm#JSGCT-GUID-23844E39-7499-400C-A579-032B68E53073
[python GC]: https://docs.python.org/3/library/gc.html
[padding]: https://github.com/golang/go/blob/master/src/runtime/map.go#L158
[boundary check]: https://github.com/golang/go/blob/master/src/encoding/binary/binary.go#L77
[simdjson]: https://github.com/simdjson/simdjson
[simdjson-infoQ]: https://www.youtube.com/watch?v=wlvKAT7SZIQ
[p-local]: https://github.com/golang/go/blob/master/src/sync/pool.go#L47
[inline]: https://github.com/golang/go/blob/master/src/sync/once.go#L59
