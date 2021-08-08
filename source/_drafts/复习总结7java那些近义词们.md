---
title: 复习总结(7)Java那些近义词们
tags: []
id: '97'
categories:
  - - Java
date: 2018-04-06 08:19:25
---

### int 和Ingeter

int是Java的基本数据类型。Java是面向对象的，这就带来了一些不便，所以需要包装类，把基本类型装箱称为对象。所以Ingeter是包装类，把基本类型包装为一个对象。相似的还有float和Float，double和Double等。 详细参考包装类基本知识。 相关问题： 包装类和基本数据类型的==结果 包装类之间的==结果  

### String、StringBuffer和StringBuilder

String是不可变对象，StringBuffer和StringBuilder是可变对象。 StringBuffer线程安全，StringBuilder线程不安全。 通常情况下，优先使用StringBuilder，因为没有线程同步，使得效率更高。 通常不使用String，因为不可变对象在每次修改的时候都会创建新对象，过多旧对象回收会影响效率。

### Hashtable和Hashmap

Hashtable线程安全，Hashmap需要手动同步。 Hashtable不允许null，Hashmap允许null（两者都包括key和value） Hashmap是新框架用来代替Hashtable的类，建议使用Hashmap  

### Arraylist和Vector

Vector有线程同步，线程安全，同时也导致访问相对较慢。 都是使用数组进行存储，但是每次扩充的大小不一样。  

### 多线程的run和start

只调用run，实际上只是单纯的调用，没有多线程运行，后续语句会等待调用执行完再继续进行。 调用start后，启动了一个新进程并使进程进入就绪态，但是并没有立即启动。当得到时间片后，就会调用run方法。  

### sleep和wait

sleep在睡眠时，仍然持有锁。 wait在睡眠时释放锁。 实际上线程的状态也不一样。 ![](http://makdon.me/wp-content/uploads/2018/04/174442_0BNr_182175-1.jpg) 图来自https://my.oschina.net/mingdongcheng/blog/139263

### collection 和 collections

java.util.Collection 是一个**集合接口**。它提供了对集合对象进行基本操作的通用接口方法。Collection接口在Java 类库中有很多具体的实现。Collection接口的意义是为各种具体的集合提供了最大化的统一操作方式。 java.util.Collections 是一个包装类。它包含有各种有关集合操作的**静态多态方法**。此类**不能实例化**，就像一**个工具类**，服务于Java的Collection框架。 （原出处不详）