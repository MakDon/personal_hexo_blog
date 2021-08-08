---
title: Tokens in Python
tags: []
id: '136'
categories:
  - - 数据结构与算法
date: 2018-11-05 15:16:26
---

本文主要归纳python的parse过程中，词法分析中，生成的Token的名字以及其含义。 此文章归纳自https://github.com/python/cpython/blob/3.6/Parser/tokenizer.c，版本为python3.6。  

"ENDMARKER",

结束标记符

"NAME",

名字

"NUMBER",

数字

"STRING",

字符串

"NEWLINE",

换行

"INDENT",

缩进

"DEDENT",

未明，在tokenizer.c里面找不到

"LPAR",

左括号(

"RPAR",

右括号)

"LSQB",

左中括号\[

"RSQB",

右中括号\]

"COLON",

冒号:

"COMMA",

逗号,

"SEMI",

分号;

"PLUS",

加号+

"MINUS",

减号-

"STAR",

星号\*

"SLASH",

斜杠/

"VBAR",

或号

"AMPER",

与&

"LESS",

小于号<

"GREATER",

大于号>

"EQUAL",

等于号=

"DOT",

点.

"PERCENT",

百分号%

"LBRACE",

左花括号{

"RBRACE",

右花括号}

"EQEQUAL",

判断相等==

"NOTEQUAL",

不相等!=或者<>

"LESSEQUAL",

小于等于<=

"GREATEREQUAL",

大于等于>=

"TILDE",

波浪线~

"CIRCUMFLEX",

音调符号^

"LEFTSHIFT",

左移<<

"RIGHTSHIFT",

右移>>

"DOUBLESTAR",

双星号\*\*

"PLUSEQUAL",

加等于+=

"MINEQUAL",

减等于

"STAREQUAL",

星等于\*=

"SLASHEQUAL",

除等于/=

"PERCENTEQUAL",

百分号等于%=

"AMPEREQUAL",

与等于&=

"VBAREQUAL",

或等于=

"CIRCUMFLEXEQUAL",

次等于^=

"LEFTSHIFTEQUAL",

左移等于<<=

"RIGHTSHIFTEQUAL",

右移等于>>=

"DOUBLESTAREQUAL",

双星号等于\*\*=

"DOUBLESLASH",

双斜杠//

"DOUBLESLASHEQUAL",

双斜杠等于//=

"AT",

AT号@

"ATEQUAL",

@=

"RARROW",

\->

"ELLIPSIS",

省略号...

/\* This table must match the #defines in token.h! \*/

"OP",

"AWAIT",

关键字await

"ASYNC",

关键字async

"<ERRORTOKEN>",

错误的token

"<N\_TOKENS>"

不知道是啥