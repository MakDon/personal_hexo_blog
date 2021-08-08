---
title: 编程题：贪吃的小Q-算法题记录
tags: []
id: '145'
categories:
  - - 数据结构与算法
date: 2019-03-04 23:54:15
---

:前几天隔壁宿舍同学在刷算法题，串门的时候看到了这道有趣的题，记录一下。 原题目是这样的： 链接：[](https://www.nowcoder.com/questionTerminal/d732267e73ce4918b61d9e3d0ddd9182?orderByHotValue=1&page=1&onlyReference=false)[https://www.nowcoder.com/questionTerminal/d732267e73ce4918b61d9e3d0ddd9182?orderByHotValue=1&page=1&onlyReference=false](https://www.nowcoder.com/questionTerminal/d732267e73ce4918b61d9e3d0ddd9182?orderByHotValue=1&amp;page=1&amp;onlyReference=false) 来源：牛客网 小Q的父母要出差N天，走之前给小Q留下了M块巧克力。小Q决定每天吃的巧克力数量不少于前一天吃的一半，但是他又不想在父母回来之前的某一天没有巧克力吃，请问他第一天最多能吃多少块巧克力

##### **输入描述:**

每个输入包含一个测试用例。
每个测试用例的第一行包含两个正整数，表示父母出差的天数N(N<=50000)和巧克力的数量M(N<=M<=100000)。

##### **输出描述:**

输出一个数表示小Q第一天最多能吃多少块巧克力。

示例1

## 输入

3 7

## 输出

4

一开始打算找规律，使用2的n次方进行分配，最后也没有得出一个好的解法（虽然已经很接近了），于是看了一下牛客的参考答案，主要是两种解法：

#### 二分查找法：

非常暴力的方法，意料之外情理之中。需要的结果为“第一天最多可以吃多少个”，这个值一定在0与巧克力总数M之间。于是可以在\[0,M\]区间内进行二分查找。复杂度为O(logM·N)，代码如下：

//@小冲冲

#include
using namespace std;
int n,m;
//计算第一天吃s个巧克力一共需要多少个多少个巧克力
int sum(int s){
    int sum=0;
    for(int i=0;i<n;i++){ sum+=s; s=(s+1)>>1;//向上取整
    }
    return sum;
}
//二分查找
int fun(){
    if(n==1) return m;
    int low=1;
    int high=m;//第一天的巧克力一定是大于等于1小于等于m的
    while(low<high){ int mid=(low+high+1)>>1;//向上取整
        if(sum(mid)==m) return mid;//如果第一天吃mid个巧克力，刚刚好吃完所有巧克力，那么直接返回
        else if(sum(mid)<m){ low=mid; }else{ high=mid-1; } } return high; } int main() { cin>>n>>m;
    int res=fun();
    cout<<res<<endl;
    return 0;
}

但是我个人觉得这个想法不太elegant，复杂度仍有一些高，于是再往下翻，找到一个比较有意思的解法，跟我一开始的想法差不多。他没有标明他的方法，我给他随便起个名字：

#### 逐次分配法：

他的思路如下：

1.  首先，每天分配一颗巧克力
2.  计算得到剩余的可分配巧克力
3.  按照2的N次方的顺序给各天分配，如：可分配的有7颗，则第一天分4个，第二天分2个，第三天分1个。
4.  计算剩余的巧克力数量，如果还有剩余，跳转到2
5.  没有剩余可分的巧克力，则完成分配。

代码如下：

//@域外創音
#include
#define MAX\_INDEX 17
int power2\[\] = {1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768,65536,131072};
int main()
{
    int n,m;
    std::cin>>n>>m;
    //只有1天时直接输出
    if(n==1){std::cout<<m<<std::endl;return 0;} //初始分配：每天最少吃1块     
    int alignable = m-n; 
    int result = 1; //如果可以某种power2\[i\]-1的方式分配，便进入。具体的分配是：第一天多吃power2\[i-1\]块，第二天多吃power2\[i-2\]块，依此类推。 
    //这样一来，只要每个追加分配所对应的i不重复，每天吃的块数就依然能符合要求，因为第j天吃的块数最多等于power2\[从i-j到0\]+1，一定大于power2\[从i-j-1到0\]的二倍。 
    for(int i=MAX\_INDEX-1;i>=0;i--)if(alignable>=power2\[i\]-1)
    {
        result+=power2\[i-1\];
        alignable -= (power2\[i\]-1);
    }
    std::cout<<result<<std::endl;
    return 0;
}

这个代码非常的有意思，它可以把复杂度减少到O(log(m))，并且它还通过了所有测试用例。但是，作为预备役测试猿，我找到了它一个bug（笑）。当输入用例为（3天，20块巧克力）时，跑出来的结果是10，但是实际上，可以得到（11，6，3）的分配策略，与其得到的结果不符。使用二分查找法得出的结果也为11.问题出在哪里呢，通过代码走读很容易定位到问题出在18行：

alignable -= (power2\[i\]-1);

以（3天，20块）为用例，逐步推演，即可看到问题是怎么样发生的：

![](http://makdon.me/wp-content/uploads/2019/03/Screenshot-2019-03-04-at-11.27.25-PM.png)

在第一轮分配的时候，@域外創音 的方法是，默认认为分配了pow(2,n)-1颗，而不是实际分出去的颗数。在此用例中，假如有4天或以上，分配列为（8，4，2，1），alignable -= 15无疑是正确的，但是当只有3天时，则会给不存在的第四天分配了一颗，从而导致最终结果的错误。

更正的方法也很简单，就是把alignable -= (power2\[i\]-1);改为alignable -= actually\_assigned即可，而actually\_assigned值的计算可以由代码中的i与天数n联合得出。

经过修改的代码如下，通过了牛客网的OJ所有测试用例，暂未发现未通过的其它反例。

#include<iostream>
#define MAX\_INDEX 17
int power2\[\] = {1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768,65536,131072};
int main()
{
    int n,m;
    std::cin>>n>>m;
    //只有1天时直接输出
    if(n==1){std::cout<<m<<std::endl;return 0;} //初始分配：每天最少吃1块
    int alignable = m-n;
    int result = 1; //如果可以某种power2\[i\]-1的方式分配，便进入。具体的分配是：第一天多吃power2\[i-1\]块，第二天多吃power2\[i-2\]块，依此类推。
    //这样一来，只要每个追加分配所对应的i不重复，每天吃的块数就依然能符合要求，因为第j天吃的块数最多等于power2\[从i-j到0\]+1，一定大于power2\[从i-j-1到0\]的二倍。
    for(int i=MAX\_INDEX-1;i>=0;i--)if(alignable>=power2\[i\]-1)
        {
            if(i>0)//防止越界
                result+=power2\[i-1\];
            int assigned = 0;
            if(i>n)
                assigned = (power2\[i\]-1) - (power2\[i-n\]-1);
            else
                assigned = (power2\[i\]-1);
            alignable -= assigned;
        }
    std::cout<<result<<std::endl;
    return 0;
}