---
title: overleaf 生成的文档无法被维普等查重网站识别 / Latex 文档引用为问号
tags: []
id: '154'
author: makdon
categories:
  - - 其它杂项
date: 2019-05-25 12:52:20
---

一句话解决：

安装本地 Latex 环境，并本地编译。如果引用（upcite）方括号里面是问号，那就再敲一次编译命令。

###### 故事背景

重要的热心群众小金给了在下一个 Latex 模板，然后给我推荐了 overleaf 这个在线写 Latex 的网站。一路用得很 high，排版是真的非常 elegant ，体验比 Word 不知道高到哪里去。当我愉快地完成论文写作，用 overleaf 编译了 pdf 准备去查重的时候，发现 维普 和 paperpass 这两个网站都没办法读入我的 pdf 文件：维普不能看到读入了什么，但是指出我的文章只有1000+字符，只收我 6 块钱；paperpass 可以看见 pdf 解析之后是一堆乱码。只有 paperyy 这个查重平台可以认出我的 pdf 内容（并且这个还是免费查重，比较适合初稿查重）

###### 系统环境

文档用的 xelatex 编译器，tex 文件使用 UTF-8 编码，图片使用 PNG 格式。使用 ctex 中文包，导入时如下：

\\usepackage{ctexcap}

本地编译操作系统为 MacOS Majave，xelatex 编译器版本信息如下：

XeTeX 3.14159265-2.6-0.99999 (TeX Live 2018)
kpathsea version 6.3.0
Copyright 2018 SIL International, Jonathan Kew and Khaled Hosny.
There is NO warranty.  Redistribution of this software is
covered by the terms of both the XeTeX copyright and
the Lesser GNU General Public License.
For more information about these matters, see the file
named COPYING and the XeTeX source.
Primary author of XeTeX: Jonathan Kew.
Compiled with ICU version 61.1; using 61.1
Compiled with zlib version 1.2.11; using 1.2.11
Compiled with FreeType2 version 2.9.0; using 2.9.0
Compiled with Graphite2 version 1.3.11; using 1.3.11
Compiled with HarfBuzz version 1.7.6; using 1.7.6
Compiled with libpng version 1.6.34; using 1.6.34
Compiled with poppler version 0.63.0
Using Mac OS X Core Text and Cocoa frameworks

###### 解决方法：

用本地编译，用本地编译，用本地编译

在我准备用 Word 重新排版论文的时候，我就想，不如死马当活马医，本地编译再提交看看。一开始我没有抱有什么希望，直觉上觉得，不同地方编译出来的 pdf 应该是一样的。于是我就试了试用本地编译，用的命令如下：

xelatex tex.tex

其实我对本地命令行用 Latex 算是一窍不通，于是没有加什么参数（也不知道有什么参数）。连这条命令都是靠直觉蒙中的。

打完命令后，他给我刷刷刷了几个屏幕的信息，然后说，生成好了。对比发现实际生成的东西并不一样，字体变了，然后发现引用框框里面都是问号。然后查来查去，国内博客互相抄来抄去都是说 xx 的 IDE 上面怎么样操作，不过还好最后在歪果论坛的深处，有人说，再打一遍命令就好了。于是我就：

xelatex tex.tex
xelatex tex.tex

后面一次生成的 pdf 会自动覆盖前一次的。当他刷刷刷了一大串东东之后，pdf 就生成好了。然后丢给维普，维普正常认出来了（然后收了我50多块钱），paperpass导入也正常了。

至此，Latex 的查重问题基本解决了。