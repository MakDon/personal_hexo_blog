---
title: Windows To Go 接入parallel desktop后应用打开无反应
tags: []
id: '122'
author: makdon
categories:
  - - 其它杂项
date: 2018-07-16 20:19:58
---

现象：双击exe文件后，可以在任务管理器看见进程被创建，但是随即消失，不能正常打开应用。系统内置软件则可以正常打开 解决方法：在系统设置的应用内，卸载parallel desktop tool

## 事件回顾：

之前在外置SSD内安装了一个Windows To Go，在需要的时候连接MacBook重启切换系统。在前几天，需要同时用到两个系统，于是想办法在parallel desktop内把这个系统跑起来。 当插着SSD的时候在parallel desktop内新建，可以识别出外置硬盘内装有bootcamp，但是在由bootcamp新建时，提示一个文件没有读写权限。在Google后发现Windows To Go大多数人并不是这样添加进去而是采用另一种办法： 正常新建一个Windows10的虚拟机，在选择安装源的时候选择无安装源，然后在虚拟机的启动设置内，把第一驱动顺序设置为外置SSD。我按照此方法在PD12上正常跑起来了Windows To Go，在安装了parallel desktop tool之后与原生的虚拟机无太大差别。（但是硬盘的IO速度极慢，而且在刚刚创建进桌面的时候等待时间极长） 然鹅当我想把这个SSD当做正常的Windows To Go来用的时候（即重启电脑然后设置为启动盘），发现自己安装的所有的第三方应用并不能正常打开，具体症状就是双击exe后，图形界面没有任何反应，从任务管理器可以看见进程被创建然后迅速又消失了。 在（并没有花多少时间）的排插之后，认定是parallel desktop的问题，卸载tool之后重启一切正常。猜测应该是tool在中间有一步会跟被寄生系统进行交互（例如添加dock图标），但是不在虚拟机启动的话并不能调用相关的组件，导致加载失败退出。