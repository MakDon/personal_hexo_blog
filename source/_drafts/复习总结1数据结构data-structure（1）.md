---
title: 复习总结(1)数据结构data structure（1）
tags: []
id: '29'
categories:
  - - 数据结构与算法
date: 2018-03-28 00:00:04
---

对学过的数据结构做一个简单的归纳总结，且作为以后的复习提纲。

图片未标明出处的均为使用ProcessOn（[https://www.processon.com/）作图](https://www.processon.com/）作图)。

#### 数组（Array）

线性结构。

![](http://makdon.me/wp-content/uploads/2018/03/AMGYATKDD9NJY3UD24T.png)

#### 链表（Linked List）

包括单向链表（Singly linked list）、双向链表（Doubly linked list）、循环链表（Circular linked list）等。

单向链表 ----Wikipedia

![](http://makdon.me/wp-content/uploads/2018/03/O_W1VBNTYEIS2IV_1O.png)

双向链表 ----Wikipedia

![](http://makdon.me/wp-content/uploads/2018/03/2IUGN6UU3KJ6JKZ4W.png)

循环链表----Wikipedia

![](http://makdon.me/wp-content/uploads/2018/03/YZCVQ1OLOQRM6P1L8B0_V.png)

#### 队列（queue）

先进先出（First-In-First\_Out）的线性表(Linear List)，常用数组(Array)或者链表(Linked list)实现。

![](file:///C:\Users\Mak\AppData\Roaming\Tencent\Users\379857334\TIM\WinTemp\RichOle\6`(A6{@REH5UL`K~{7J`9)9.png)![](http://makdon.me/wp-content/uploads/2018/03/54BF6FN46U5S29OV7I.png)

##### 栈（Stack）

先进后出（First-In-Last-Out），从同一端进（push）和出（pop）

![](http://makdon.me/wp-content/uploads/2018/03/7IQ45E16HNGSJWQ07.png)

#### 哈希表（Hash Table）

散列函数为F()，通过index = F(key)获得元素在哈希表内的位置。

![](http://makdon.me/wp-content/uploads/2018/03/XQYLDWPSCH0RY@YY.png)\---Wikipedia

重点：

哈希函数（Hash function）

冲突处理（Collision resolution）

#### 堆（heap）

使用线性结构存储的二叉树（通常情况下），满足

(ki <= k2i, ki <= k2i+1)或者(ki >= k2i, ki >= k2i+1), (i = 1, 2, 3, 4... n/2) ---wikipedia

常用于堆排序

![](http://makdon.me/wp-content/uploads/2018/03/YS5WL53MSG7@@G.png)