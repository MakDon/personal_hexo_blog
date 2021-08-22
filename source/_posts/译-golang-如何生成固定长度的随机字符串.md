---
title: '译: Golang 如何生成固定长度的随机字符串'
tags: []
id: '203'
author: makdon
categories:
  - - 数据结构与算法
date: 2020-12-17 00:57:17
---

译者写在前面：之前在 Stack Overflow 看到了这个回答，感觉很多优化思路可以用在日常的开发之中。搜了一下中文社区没找到该回答翻译，所以打算翻译成中文，这样我的博客就可以又多一篇水文。 需要注意的是，该文的各种优化方法之后，代码可读性会非常的差，在日常工作中这样写需要注意人身安全。 不过很多优化的思想还是值得借鉴的。

原文地址[点击这里](https://stackoverflow.com/questions/22892120/how-to-generate-a-random-string-of-a-fixed-length-in-go)

# 以下是原文的译文

[Paul](https://stackoverflow.com/questions/22892120/how-to-generate-a-random-string-of-a-fixed-length-in-go/22892986#22892986) 的解决方案提供了一个简单普遍的解法。

该问题再寻求“最快和最简单的方法”。我们来着眼于**最快**。我们会一步一步得出我们一个最终的最快的版本。每一步的 benchmark 结果会附在本回答的最后。

所有的方案和性能测试的代码可以在[这个 Go playground](https://play.golang.org/p/KcuJ_2c_NDj)看到. 这些代码是一个 test 文件，而不是一个可直接执行的代码。你可以把它保存成`XX_test.go`然后用以下命令执行

```shell
go test -bench . -benchmem
```

写在前面：

如果你只是需要一个随机字符串，最快的解决方案并不是首选方案，[Paul 的解决方案](https://stackoverflow.com/questions/22892120/how-to-generate-a-random-string-of-a-fixed-length-in-go/22892986#22892986)已经足够了。这个最快的方案仅使用于性能敏感的场景。虽然前两步的优化已经足够使用了，它在原来的基础上提升了 50%的性能。（具体数值参考 Benchmark 一章），而且不会让代码变得太复杂。

不过，即使你不需要最快的解法，看完这个回答可能会有点挑战性而又可以从中学到东西。

## I. 优化

### 1\. 起源（字符）

我们要优化的最原始的一般解法像这样

```Golang
func init() {
    rand.Seed(time.Now().UnixNano())
}

var letterRunes = []rune("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")

func RandStringRunes(n int) string {
    b := make([]rune, n)
    for i := range b {
        b[i] = letterRunes[rand.Intn(len(letterRunes))]
    }
    return string(b)
}
```

### 2\. Bytes

如果我们的随机字符串仅由英语字母大小写组成，我们可以只使用 bytes 因为英文字母跟 byte 是一一对应映射的（Go 存储strings 的方式）  
所以，对于原来的语句

```Golang
var letters = []rune("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
```

我们可以替换为

```Golang
var letters = []bytes("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
```

或者这样甚至更好

```Golang
const letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
```

现在已经是一个很大的优化了：我们可以把它声明成 const（Go 中有 string 常量但是[没有 slice 常量](https://stackoverflow.com/a/29365828/1705598)）。额外的收益是，`len(letters)`也会是一个常量(当 s 是一个string常量时，表达式`len(s)`也是常量)

那成本呢？没有任何成本。我们可以通过 index 拿到 string 中的 byte。

优化完后，我们的代码如下:

```Golang
const letterBytes = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

func RandStringBytes(n int) string {
    b := make([]byte, n)
    for i := range b {
        b[i] = letterBytes[rand.Intn(len(letterBytes))]
    }
    return string(b)
}
```

### 3\. 取余

上一个解法中，我们通过 `rand.Intn()`获得一个随机字符，而 `Rand.Intn()` 是委托给 `Rand.Int31n()` 执行的。

所以相比于一次生成 63个随机bit 的 `rand.Int63()`来说，它要慢得多。

所以我们可以直接使用`rand.Int63()` 然后使用它除以 `len(letterBytes)` 的余数:

```Golang
func RandStringBytesRmndr(n int) string {
    b := make([]byte, n)
    for i := range b {
        b[i] = letterBytes[rand.Int63() % int64(len(letterBytes))]
    }
    return string(b)
}
```

它要显著地比之前的解法快得多地完成了任务，缺点是所有字母出现的概率并不是完全一致的（假定`rand.Int63()`生成所有 63位数字的概率相等）。  
不过这个差异足够小, 因为共计52个字符，这个数量远远小于 `1<<63-1`，所以在实践中使用是没有问题的。

用更简单的角度解释一下：假如你需要从 0\\~5中随机挑一个数值，当使用 3个随机位，获得0\\~1的概率比2\\~5的概率要大一倍。使用 5个随机位，0\\~1 出现的概率是 `6/32`, 2\\~5 出现的概率是`5/32`，更接近期望的值了。增大随机位的数量使差异更小，当达到 63位时，差异可忽略不计。

### 4\. 掩码

基于上一个解法，我们可以只用低几位的 bit 来获得我们想要的一个字母。如果我们有 52个字母，我们需要用 6个 bit 来表示它: `52 = 110100b`。所以我们可以只用`rand.Int63()`返回的低 6位。若要使所有字符出现的概率相等，我们只使用那些位与区间`0\~len(letterBytes)-1`的数字。如果最低的几位比这个要大，那我们重新生成一个新的随机数。

需要提醒的是，最低几位大于`len(letterBytes)` 的概率通常低于 0.5（平均来说是 0.25)，意味着我们只需要重复几次，无法获得值域内的随机数的概率就会大大降低。在 n 次随机后，我们无法获得一个合适的下标的概率远低于 `pow(0.5,n)`，而这已经是一个较高的估计了。 当我们有 52个字符是，低 6位不能用的概率仅为 `(64-52)/64 = 0.19`，因此例子中循环 10次拿不到一个合适的随机数的概率是 `1e-8`

然后这是解法：

```Golang
const letterBytes = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
const (
    letterIdxBits = 6                    // 用 6位表示一个字母的下标
    letterIdxMask = 1<<letterIdxBits - 1 // 数量和 letterIdxBits 一样多的 为 1的位
)

func RandStringBytesMask(n int) string {
    b := make([]byte, n)
    for i := 0; i < n; {
        if idx := int(rand.Int63() & letterIdxMask); idx < len(letterBytes) {
            b[i] = letterBytes[idx]
            i++
        }
    }
    return string(b)
}
```

### 5\. 掩码优化版

上一个解法只用了 `rand.Int63()` 返回的63位中的低 6位。我们算法中耗时最长的就是获取随机数，因此我们浪费了非常多的计算资源。  
如果我们有 52个字母，意味着每 6位可以唯一索引一个字母。因此 63随机位可以可以指定 `63/6 = 10` 个不同的字母。我们可以把这 10个都用上:

```Golang
const letterBytes = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
const (
    letterIdxBits = 6                    // 6 bits to represent a letter index
    letterIdxMask = 1<<letterIdxBits - 1 // All 1-bits, as many as letterIdxBits
    letterIdxMax  = 63 / letterIdxBits   // # of letter indices fitting in 63 bits
)

func RandStringBytesMaskImpr(n int) string {
    b := make([]byte, n)
    // A rand.Int63() generates 63 random bits, enough for letterIdxMax letters!
    for i, cache, remain := n-1, rand.Int63(), letterIdxMax; i >= 0; {
        if remain == 0 {
            cache, remain = rand.Int63(), letterIdxMax
        }
        if idx := int(cache & letterIdxMask); idx < len(letterBytes) {
            b[i] = letterBytes[idx]
            i--
        }
        cache >>= letterIdxBits
        remain--
    }

    return string(b)
}
```

### 6\. 源

上一个`掩码优化版` 已经非常好了，没有太多的改进空间了。我们可以加以改进，不过引入的复杂度不一定值得。  
现在我们来看其它可以优化的地方。**随机数生成源**  
`crypto/rand` 包提供了 `Read(b []byte)` 函数，所以我们可以一次调用就获得足够多 byte。不过这对于我们的问题并没有什么作用，因为`crypto/rand` 实现了加密安全的伪随机数生成算法而导致它的性能要慢得多。  
我们看回来`math/rand` 包。 `rand.Rand` 使用了 `rand.Source` 作为随机位生成源。`rand.Source` 是一个接口，指定了一个 `Int63() int64` 方法：--在我们只需要这个。  
所以我们其实并不需要 `rand.Rand` (无论隐式或全局变量，被包含在 `rand` 包中的)，一个 `rand.Source` 已经完美地满足我们的需要了。

```Golang
var src = rand.NewSource(time.Now().UnixNano())

func RandStringBytesMaskImprSrc(n int) string {
    b := make([]byte, n)
    // A src.Int63() generates 63 random bits, enough for letterIdxMax characters!
    for i, cache, remain := n-1, src.Int63(), letterIdxMax; i >= 0; {
        if remain == 0 {
            cache, remain = src.Int63(), letterIdxMax
        }
        if idx := int(cache & letterIdxMask); idx < len(letterBytes) {
            b[i] = letterBytes[idx]
            i--
        }
        cache >>= letterIdxBits
        remain--
    }

    return string(b)
}
```

这个解法并不需要你去初始化(`seed`) `math/rand`包中全局的 `Rand` 因为我们没有用到它，我们用到的 `rand.Source` 已经被初始化好了。  
还有一个需要注意的， `math/rand` 的文档中注明了: 默认的 Source 是并发安全的，可以被用于多个 Goroutine 中 所以默认的随机数源要比从 `rand.NewSource()` 获得的随机数源要慢的多，因为默认的随机数源需要保证并发调用下的协程安全，而 `rand.NewSource()` 并没有提供这种保证（从而它返回的随机数源更可能要快一些）

### 7\. 使用`strings.Builder`

之前的所有解法都返回一个 `string`, 而这个 `string` 都是先用切片拼凑起来的(最初的解法是`[]rune`，然后使用`[]byte`), 然后再转换成 `string`。最后的类型转换会铲屎一个切片内容的值拷贝，因为 `string` 的值是不可变的，如果转换不进行一次值拷贝，无法保证这个字符串的内容不因原始切片被改变而改变。更详细的信息可以参考\[How to convert utf8 string to \[byte?\][How to convert utf8 string to \[\]byte?](https://stackoverflow.com/questions/41460750/how-to-convert-utf8-string-to-byte/41460993#41460993) 和 \[\[\]byte(string) vs \[\]byte(\*string)\]

[Go 1.10 引入了 strings.Builder](https://golang.org/doc/go1.10#strings). 我们可以像用`bytes.Buffer` 一样使用 `strings.Builder` 构建字符串的内容。它内部的确使用了一个 \[\]byte，当我们操作完成后，我们通过 `Builder.String()` 获得最终的字符串值。但是有意思的是，他不需要进行像我们刚刚谈到的值拷贝。它之所以可以不拷贝，是因为用于构建字符串的 slice 并没有暴露出去，因此并没有办法可以无意或恶意地修改生成的”不可变“的字符串。

所以我们下一步就是，不通过切片生成一个随机字符串，而是使用 `strings.Builder`, 当我们完成后，我们可以生成并返回，而无需再进行一次拷贝。它可能会在速度上有所帮助，而且它无疑会优化内存占用和分配。

```Golang
func RandStringBytesMaskImprSrcSB(n int) string {
    sb := strings.Builder{}
    sb.Grow(n)
    // A src.Int63() generates 63 random bits, enough for letterIdxMax characters!
    for i, cache, remain := n-1, src.Int63(), letterIdxMax; i >= 0; {
        if remain == 0 {
            cache, remain = src.Int63(), letterIdxMax
        }
        if idx := int(cache & letterIdxMask); idx < len(letterBytes) {
            sb.WriteByte(letterBytes[idx])
            i--
        }
        cache >>= letterIdxBits
        remain--
    }

    return sb.String()
}
```

需要留意的是，当我们创建了一个新的 `strings.Builder`后，我们调用它的 `Builder.Grow()`， 让它分配足够大的内部切片，以避免我们增加随机字符后，需要进行内存的再分配）

### 8\. 模仿 `strings.Builder` 使用 `unsafe` 包

`string.Builder` 使用内部 `[]byte` 构建字符串，我们自己也可以这样做。我们用`strings.Builder` 只是是为了避免最后的切片拷贝，而它本身也会带来一些额外开销。

`strings.Builder` 使用 `unsafe` 包来避免最终的拷贝:

```Golang
// String returns the accumulated string.
func (b *Builder) String() string {
    return *(*string)(unsafe.Pointer(&b.buf))
}
```

问题是，我们自己也可以这样做。所以这里的方法是，我们回到上一个使用`[]byte`构建字符串的方法，不过当我们构建完成后，不要把它转换成 `string`，而是做一个”不安全的转换“：获得一个指向我们的字节片但把它作为字符串数据的字符串。

我们可以看这里的代码：

```Golang
func RandStringBytesMaskImprSrcUnsafe(n int) string {
    b := make([]byte, n)
    // A src.Int63() generates 63 random bits, enough for letterIdxMax characters!
    for i, cache, remain := n-1, src.Int63(), letterIdxMax; i >= 0; {
        if remain == 0 {
            cache, remain = src.Int63(), letterIdxMax
        }
        if idx := int(cache & letterIdxMask); idx < len(letterBytes) {
            b[i] = letterBytes[idx]
            i--
        }
        cache >>= letterIdxBits
        remain--
    }

    return *(*string)(unsafe.Pointer(&b))
}
```

### (9. 使用`rand.Read()`)

[Go 1.7 新增](https://golang.org/doc/go1.7#math_rand) 一个`rand.Read()` 函数和一个 `Rand.Read()` 方法。我们可能会想用这个方法一次性获得足够多 byte 以达到更高的效率。

但是这有一个小"问题"：我们需要多少字节？我们可以假设：要跟输出的字母数一样。我们可以认为这是一个向上的约数，因为一个字母索引需要少于 8位（一个字节）。但是这个解法没有上面的好，因为获取随机位是计算中最重的部分，而我们获取到的比我们需要的还要多。

还需要留意的是，为了让每个字母出现的概率一致，也许会有一些被丢弃的随机数据，所以我们可能有可能因为跳过了一些随机数据而导致最后获得的字符串不够长。然后我们需要”递归地“获取更多随机字节。现在我们连”只需要调用一次`rand`包“的优点都没有了。

我们可以某种程度上优化我们使用`math.Rand()`生成的随机数据的方法。我们可以预估我们需要多少字节（位）。一个字母需要 `letterIdxBits` 位，我们需要 `n` 个字母，所以四舍五入我们需要`n * letterIdxBits / 8.0` 字节。我们可以计算一个随机索引不可用的概率，所以我们可以获取多一些数据以便更可能足够使用（如果不够的话，重复这个过程）。例如我们可以用`github.com/icza/bitio`这个第三方库把字节切片当成 bit 流来使用。

但是基准测试中它的性能仍然没有以上好，为什么呢？

因为`rand.Read()` 使用循环调用 `Source.Int63()` 直到传入的切片填满，实际上就是没有中间 buffer 和更多复杂度的`RandStringBytesMaskImprSrc()`这个解法，这就是`RandStringBytesMaskImprSrc()`表现更好的原因。 是的`RandStringBytesMaskImprSrc()`使用了不同步的`rand.Source` 而不像 `rand.Read()`，不过上面的理由依然成立，我们可以使用`Rand.Read()` 替换 `rand.read()`来证明（前者也是不同步的）

## II. 基准测试

好了，是时候看看不同解法的基准测试结果

```
BenchmarkRunes-4                     2000000    723 ns/op   96 B/op   2 allocs/op
BenchmarkBytes-4                     3000000    550 ns/op   32 B/op   2 allocs/op
BenchmarkBytesRmndr-4                3000000    438 ns/op   32 B/op   2 allocs/op
BenchmarkBytesMask-4                 3000000    534 ns/op   32 B/op   2 allocs/op
BenchmarkBytesMaskImpr-4            10000000    176 ns/op   32 B/op   2 allocs/op
BenchmarkBytesMaskImprSrc-4         10000000    139 ns/op   32 B/op   2 allocs/op
BenchmarkBytesMaskImprSrcSB-4       10000000    134 ns/op   16 B/op   1 allocs/op
BenchmarkBytesMaskImprSrcUnsafe-4   10000000    115 ns/op   16 B/op   1 allocs/op
```

只需要从 runes 切换到 bytes，我们即可获得 24% 的性能提升，同时内存占用降至原来的 **三分之一**

使用 `rand.Int63()` 代替`rand.Intn()`可以再获得 20%的性能提升

使用掩码（如果索引过大就重算）比它的上一个解法更慢一些： -22%

但是当我们使用所有（或者说，大部分）的63个随机位（一次调用获取10个索引）：3倍于上一个解法的效率。

如果我们使用一个非默认的全新`rand.Source`而不是`rand.Rand`，我们再获得 22%的性能提升。

如果我们使用 `strings.Builder`, 我们获得微小的 3.5%的效率提升，但是我们减少了 50%的内存占用和分配。

最后如果我们敢于使用 `unsfae`包而不是 `rand.Rand`，我们可以获得一个不错的 14%提升。

把最后的解法与最初的解法对比，`BenchmarkBytesMaskImprSrcUnsafe()` 的速度是 `BenchmarkRunes()` 的 6.3倍，只使用了六分之一的内存和二分之一次内存分配。

到此我们的任务已经完成了。