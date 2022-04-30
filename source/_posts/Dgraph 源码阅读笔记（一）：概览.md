---
title: 'Dgraph 源码阅读笔记（一）：概览'
date: 2022-04-30 23:01:04
tags: ['Go']
author: makdon
---

# Dgraph 源码阅读笔记（一）：概览

[Dgraph] 是一个几乎完全由 Golang <a href="#### 1:"><sup>1</sup></a> 编写的原生分布式图数据库。它是完全开源的，对应的 github 页面在 [这里][Dgraph-github]

本文是个人源码阅读笔记。本篇主要记录整个图数据库的概览，架构，以及如何入手阅读源码。
在阅读源码前，先起步于阅读官方的[论文][Dgraph-paper], 以对其有个宏观上的大致了解。

## 2. 架构总览

循着官方的[论文][Dgraph-paper], 可以找到个架构的总览:

![architecture][architecture]

参考架构图，Dgraph 由一个 Zero Group 和若干 Alpha Group 组成。     
其中每个 Group 又由多个 member 组成一个 raft 组，有一个 leader 和若干 follower。这样可以保证每个 group 都是高可用的。
Zero 固定为 Group 0，在整个 Dgraph 中为中央管理的角色，保存集群的元数据和管理全局时钟，以及进行其它集群管理的工作，跟 TiDB 的 [PD cluster] 有异曲同工的意味。
Alphas 则是用于保存用户存储的数据。Alphas 支持横向扩展，以支持更大的存储空间和读查性能。

## 2.1 & 2.2 存储格式与存储

一个三元组包括 "主体-谓词-对象" 或者 "主体-谓词-数值" (subject-predicate-object or a subject-predicate-value)
例如这样的一个结构体:
```
{
  "uid"   : "0xab",
  "type"  : "Astronaut",
  "name"  : "Mark Watney",
  "birth" : "2005/01/02",
  "follower": { "uid": "0xbc", ... },
}
```

可以表现为以下的 4个三元组:
```
<0xab> <type>  "Astronaut" .
<0xab> <name>  "Mark Watney" .
<0xab> <birth> "2005/01/02" .
<0xab> <follower> <0xbc> .
```

数据被存储于内嵌的 kv 数据库 [BadgerDB] 中, 就如 etcd 使用 [bbolt] 进行 kv 的存储。
[BadgerDB] 处理了跟操作系统和磁盘的操作和逻辑，对上层提供一个可靠的 kv 存储层。

所有具有相同谓词 `predicate` 的数据会被组成一个分片。
同一个分片中，具有同样"主体-谓词"`subject-predicate` 的三元组会被分到同一个 key 中，它的 value 则组成了一个 `posting list`
例如以下若干个个三元组，因为都是`<0x01> <follower>`, 因此会被存储到同一个 BadgerDB 的 key-value 中:
```
<0x01> <follower> <0xab> .
<0x01> <follower> <0xbc> .
<0x01> <follower> <0xcd> .
...
key = <follower, 0x01>
value = <0xab, 0xbc, 0xcd, ...>
```

在[论文][Dgraph-paper] 2.2 中提到，posting list 使用的是 `group varint` 的编码方式，不过在新版本中，已经更新为使用 `Roaring Bitmaps`, 具体可以参考 [serialized-roaring-bitmaps-golang] 这篇 blog 和对应的实现 [sroar], 如果后面不鸽的话，会写一篇这个库实现的阅读笔记，此处不再详述。

## 2.3 & 2.4 分片和再平衡

在 Dgraph 中，最小的数据单位是三元组，而在分布式存储中，需要对数据进行分片。
如果使用类似 hash 之后分片之类的算法，这会在一些场景上遇到性能问题。
因此，Dgraph 把谓词相同的三元组分在同一个分片中。下面用论文中的例子来讨论这样分片的好处。
假设我们有这些数据:
```
<person-a> <lives-in> <sf> .
<person-a> <eats> <sushi> .
<person-a> <eats> <indian> .
...
<person-b> <lives-in> <nyc> .
<person-b> <eats> <thai> .
```
例如我们有一个查询: `people who live in SF and eat Sushi`

这时候，只需要从分片 `<lives-in>` 查处有哪些人 live in SF，从分片 `<eats>` 查出有哪些人 eat sushi，
因为按照谓词进行分片，因此这个查询只会涉及 `<lives-in>` 和 `<eats>`, 而如果使用 hash 之类的算法，则会导致所有的分片都需要进行查询。
在这两个分片查询后，分别得出两个 posting list，只需要由其中一个分片的 host 把 posting list 发送到另一个 host，则可以算出两者的交集。而 hosting list 通常使用适合高效计算交集并集的数据结构进行实现。
回顾一下这个查询，共需两次硬盘索引查询，一次网络交互，最后算一次交集，即可得出结果。由此可见，这种分片方式十分适合图数据库的查询场景。

![data-sharding][datasharding]

如上可见，同一个谓词会被分到同一个分片中。每一个 Alphas group 上会分布若干分片，而随着使用，不同 group 上的负载可能会由于分片数的变化而变得不平衡。
Zero 会根据数据大小，对分片进行再平衡：先把分片设为只读，然后并发遍历所有的 key，并把它发给目标 group 的 leader，目标 group 的 leader 通过 raft 协议把数据落盘到整个 group 中。完成传输后，Zero 会把分片标记到目的 group 上，然后把原 group 上的数据删除，即完成了数据的再平衡。

## 小结

至此，已经可以勾勒出 Dgraph 的大致框架了，即使用 Zero 进行集群管理，Alphas 进行数据存储，把数据和索引表示为三元组并存储于 kv 数据库中，使用 raft 一致性算法进行组内数据同步和高可用。
在论文的其余章节，描述了包括但不限于 索引, 事务&MVCC，副本&高可用&横向扩展，等内容。此处不再详细展开，在明白大致框架之后，即可以开始入手阅读源码了。

## 附录

#### 1

部分内存管理相关代码使用了 cgo ，以便使用 c 的内存管理绕开 Golang 原生的 gc 机制，以达到更好的性能。

[Dgraph]: https://dgraph.io/
[Dgraph-github]: https://github.com/dgraph-io/dgraph
[Dgraph-paper]: https://github.com/dgraph-io/dgraph/blob/master/paper/dgraph.pdf
[architecture]: https://github.com/dgraph-io/dgraph/raw/master/paper/architecture.png
[PD cluster]: https://docs.pingcap.com/tidb/stable/tidb-architecture#placement-driver-pd-server
[BadgerDB]: https://github.com/dgraph-io/badger
[bbolt]: https://github.com/etcd-io/bbolt
[serialized-roaring-bitmaps-golang]: https://dgraph.io/blog/post/serialized-roaring-bitmaps-golang/
[sroar]: https://github.com/dgraph-io/sroar
[datasharding]: https://github.com/dgraph-io/dgraph/raw/master/paper/datasharding.png