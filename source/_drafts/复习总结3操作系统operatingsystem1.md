---
title: 复习总结(3)操作系统OperatingSystem(1)BasicConcepts
tags: []
id: '57'
categories:
  - - 操作系统
date: 2018-03-30 03:17:47
---

第一章：引论

1.1：作为扩展机器的操作系统

作为资源管理者的操作系统

 

1.2：操作系统的历史：

真空管和穿孔卡片

晶体管和批处理系统

集成电路芯片和多道程序设计

个人计算机

 

1.3：计算机硬件介绍：

CPU

存储器

磁盘

磁带

I/O设备

总线

启动计算机

 

1.4：各种操作系统介绍：

大型机操作系统

服务器操作系统

多处理器操作系统

个人计算机操作系统

掌上计算机操作系统

嵌入式操作系统

传感器节点操作系统

实时操作系统

智能卡操作系统

 

1.5：操作系统概念(Basic concepts)

进程

地址空间

文件

输入输出

保护

Shell

程序计数器：program counter,保存下一条指令的内存地址

堆栈指针：stack pointer,内存栈顶

程序状态字:PSW,program status word保存条件码位，CPU优先级，模式（用户/内核），其他控制位

多路复用：multiplexing

堆栈指针：stack pointer,内存栈顶

程序状态字:PSW,program status word保存条件码位，CPU优先级，模式（用户/内核），其他控制位

多路复用：multiplexing

用户态：user mode

内核态：kernel mode

系统调用：System Call，从操作系统获得服务，陷入内核并调用操作系统

Trap:Trap指令把用户态切为内核态

 

进程：Process

地址空间:address space ：从某个最小值的存储位置到最大值存储位置的列表

进程表:Process table，操作系统的一个表，数组或者链表结构，记录进程的所有信息

命令解释器:command interpreter用于从终端上读命令

进程间通讯:interprocess communication

UID: User Identification 用户标识

  ![](/img/2018/03/7K6TIHIZ8NKZ09H5.png)  

![](/img/2018/03/KBO7D47SVJ2UUQD0PHHV.jpg)