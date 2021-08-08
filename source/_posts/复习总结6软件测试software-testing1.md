---
title: 复习总结(6)软件测试software Testing(1)
tags: []
id: '86'
categories:
  - - 软件测试
date: 2018-04-03 08:02:40
---

文章内含图片均来自互联网且原作者不详

#### TDD: Test-Driven Development测试驱动开发

![](http://makdon.me/wp-content/uploads/2018/04/15226837681.png)  

#### V模型，W模型，H模型

![](http://makdon.me/wp-content/uploads/2018/04/1349748356_7491.gif) ![](http://makdon.me/wp-content/uploads/2018/04/176751dc-87bf-419c-beb3-7ce7192d27d1.jpg) ![](http://makdon.me/wp-content/uploads/2018/04/4056d3d5-b96c-4601-beac-0b01b1168d48.jpg)  

### 公理

![](file:///C:\Users\Mak\AppData\Local\Temp\1349748356_7491.gif)![](file:///C:\Users\Mak\AppData\Local\Temp\1349748356_7491.gif)![](file:///C:\Users\Mak\AppData\Local\Temp\1349748356_7491-1.gif)Axiom 1 ：It is impossible to test a program completely Axiom 2： Software testing is a risk-based exercise

![](http://makdon.me/wp-content/uploads/2018/04/3PQI8_SB3OEXD0P4.png)

Axiom 3： Testing cannot show the absence of bugs Axiom 4：The more bugs you find, the more bugs there are

Axiom 5： Not all bugs found will be fixed Axiom 6： It is difficult to say when a bug is indeed a bug Axiom 7： Specifications are never final Axiom 8： Software testers are not the most popular members of a project Axiom 9：Software testing is a disciplined and technical profession  

### 软件测试方法分类

![](http://makdon.me/wp-content/uploads/2018/04/55B0WOSM35RN0WALEF.png)  

### 测试策略的概念

![](http://makdon.me/wp-content/uploads/2018/04/1FLJ_CKS_W2XBRWZN.png)

### 测试用例

*   满足特定目的的测试数据、测试代码、测试规程的 集合
*   是发现软件缺陷的最小测试执行单元
*   有特殊的书写标准和基本原则

测试用例设计生成的基本准则： 测试用例的代表性：能够代表并覆盖各种合理的 和不合理、合法的和非法的、边界的和越界的、 以及极限的输入数据、操作和环境设置等; 测试结果的可判定性：即测试执行结果的正确性 是可判定的，每一个测试用例都应有相应的期望 结果； 测试结果的可再现性：即对同样的测试用例，系 统的执行结果应当是相同的。  

### 黑盒测试Black-Box-testing

###### 测试用例设计技术

*   等价类划分方法
*   边界值分析方法
*   错误推测方法
*   判定表驱动分析方法
*   因果图方法
*   场景法

场景法步骤总结： 1、设计场景：通过用例的主事件流和备选事 件流的组合给出不同的场景 2、设计测试用例标准覆盖场景 3、根据测试用例标准给出具体的测试数据  

### 白盒测试

逻辑分支覆盖法： 语句覆盖 判定覆盖 条件覆盖 判定/条件覆盖 条件组合覆盖 路径法： 路径覆盖 基本（独立）路径覆盖