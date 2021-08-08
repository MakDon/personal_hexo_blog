---
title: Java 版本增量覆盖率工具
tags: []
id: '164'
categories:
  - - 数据结构与算法
date: 2020-02-09 21:03:08
---

### Problem to solve

在手工测试的时候，我们的 workflow 通常是这样的：

1.  产品同学提交需求。
2.  开发同学编码。
3.  开发同学 push 代码，通过流水线进行静态检查、自动化测试，并部署到测试环境。
4.  测试同学针对需求，进行针对性手工测试。
5.  产品、设计同学走查。
6.  上线，并在需要时添加线上监控告警规则。
    
    该工具要解决的问题，就是如何较为量化、清晰地评估`第 4步：手工功能测试`的测试质量。通过该工具，生成增量测试率报告，可以清晰地看到，该 feature 更新的代码中，被手工测试覆盖到了哪些代码，哪些没有被覆盖到。
    
    ### workflow
    
    引入该工具，需要在手工测试后，生成一份覆盖率报告。大致的 workflow 变为如下：
    

1.  产品同学提交需求。
2.  开发同学编码。
3.  开发同学 push 代码，通过流水线进行静态检查、自动化测试，并部署到测试环境。
4.  测试同学针对需求，进行针对性手工测试。
5.  生成此时测试环境中的覆盖率报告。
6.  产品、设计同学走查。
7.  上线，并在需要时添加线上监控告警规则。
    
    ### 主要思路：
    
    *   通过 git diff ，获取两次发布之间的代码变更，并进行稍微处理，可以得到 map<文件名, 变更的行数>，其中文件名应包含类名，被覆盖的行数为 ArrayList\\, 行号为新版本的代码中变更的行号，如下图集合A。
    *   通过手工测试之后生成的覆盖率报告，可以获得手工测试中，已覆盖到&未覆盖到的行号。把覆盖到的行号设为集合S'
    *   A ∩ S' 即为此次发布中，更新的代码中被覆盖到的行数，未覆盖到的同理。
    *   若某行有更新，且不需要被覆盖，则在增量覆盖率报告中，体现为灰色。（如空行、注释、import）
    *   以原测试覆盖率报告为 html 模板，把第 3 步获取的行号，渲染到 html 文件中，生成新的覆盖率报告。

![](http://makdon.me/wp-content/uploads/2020/02/coverage-1.png)

### 具体实现

##### git diff

*   git diff 可以简单的通过命令行获得，注意一次发布可能包含多个commit，获取代码变更的时候需要获取多个 commit 的合并变更，具体可以参考 [这篇文档](https://git-scm.com/docs/git-diff)
    
*   git diff 输出的文件包含单个/多个文件，通过简单的字符串匹配分割，即可分割出每个文件的变更，其中变更类型可能是新增、更改、删除，文件类型可能是 text 或 binary，这里我们不对 binary 文件进行处理，直接忽略。
    
*   git diff 的每个文件变更内，包含单个/多个代码块变更，首先通过简单的字符串匹配分割，然后对每个变更块进行计数&遍历，即可获得每个代码块的变更行数，其中变更行数指修改/新增行数，被删除的行被忽略即可。把每个变更块的行号进行合并，即可获得该文件的变更行号（上图集合A）。
    

##### 报告解析

*   我们采用的是 jacoco 生成的覆盖率报告。该报告的目录结构见附录。该报告包含 index.html 为主要入口，样式被记录于`jacoco-resources/report.css`，并在浏览器打开时，使用 `jacoco-resources/prettify.js` 进行页面样式的调整与优化。
*   代码文件与报告路径可以简单地通过字符串匹配获得，如`com/foo/Bar.java` 对应 html 文件`com.foo/Bar.java.html`
*   拿取未经过 `prettify.js` 重渲染的 html观察可得，无须覆盖的行不带有 css 样式，未覆盖的行带有样式 `nc`，已覆盖的行带有样式`fc`，通过简单的字符串分割&匹配，即可得出已覆盖、未覆盖、无须覆盖的行号。

##### 报告渲染

*   改动1：调整原有CSS样式
    *   去掉原来 css 类pc, nc, fc的颜色；
    *   新增 nnc, nfc 类，使用 nc, fc的颜色，以标记未覆盖/已覆盖行
    *   新增ngc 类，颜色设置为灰色，以标记更新了但无须覆盖的行（如注释）。

*   改动2：把集合 A ∩ S' 中的行号，通过修改对应 html文件，对应行的\\ 标签添加css 类 nfc的方法，标记为已覆盖。未覆盖/无须覆盖同理。
*   改动3（TODO）：统计的 html（如`com.foo/index.html`），需要在表格内添加一列，以展示增量代码的覆盖率。

### 附录

jacoco 覆盖率报告目录结构

```
.
├── com.foo
│   ├── Bar.html
│   ├── Bar.java.html
│   ├── index.html
│   └── index.source.html
├── index.html
├── jacoco-resources
│   ├── branchfc.gif
│   ├── branchnc.gif
│   ├── branchpc.gif
│   ├── bundle.gif
│   ├── class.gif
│   ├── down.gif
│   ├── greenbar.gif
│   ├── group.gif
│   ├── method.gif
│   ├── package.gif
│   ├── prettify.css
│   ├── prettify.js
│   ├── redbar.gif
│   ├── report.css
│   ├── report.gif
│   ├── session.gif
│   ├── sort.gif
│   ├── sort.js
│   ├── source.gif
│   └── up.gif
├── jacoco-sessions.html
└── tree.output
```