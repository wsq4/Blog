#import "template.typ": *
#import "@preview/frame-it:2.0.0": *

#let problem = frame("问题", green)
#let tips = frame("提示", blue)

#show figure.where(kind: "frame"): set par(first-line-indent: 0em)
#show figure.where(kind: "frame"): set block(breakable: true)

#show: doc => template("2025S 高级算法 - Fingerprint", doc, bibliography_src: none)

= 一元 Polynomial Identity Testing

#problem[Polynomial Identity Testing][
/ 输入: 两个度数为 $d$ 的多项式 $f, g in FF[x]$
/ 输出: 判定 $f equiv g$ 

或者 

/ 输入: 一个度数为 $d$ 的多项式 $f in FF[x]$
/ 输出: 判定 $f equiv 0$ 

其中 $FF[x]$ 表示域 $FF$ 上的多项式环。

由于 $f equiv g$ 当且仅当 $f - g equiv 0$，所以前者和后者几乎是等价的。
]

域（Field）是一个集合 $K$，具有两种二元运算 
/ $plus.o$: $K times K -> K$
/ $times.o$: $K times K -> K$

满足：

- $(K, plus.o)$ 是一个阿贝尔群
  - 封闭性
  - 结合律
  - 存在单位元 $0_K$
  - 存在逆元
  - 交换律
- $(K \\ {0_K}, times.o)$ 是一个阿贝尔群
- 分配律
  
  $forall a, b, c in K$，$a times.o (b plus.o c) = (a times.o b) plus.o (a times.o c)$ 且 $(b plus.o c) times.o a = (b times.o a) plus.o (c times.o a)$

具体的域的例子有参见 #link("https://zh.wikipedia.org/zh-cn/%E5%9F%9F_(%E6%95%B0%E5%AD%A6)")[域 (数学)]。

度数为 $d$ 的多项式 $f in FF[x]$ 是指，给 $d$ 个系数 $a_0, a_1, dots, a_d in FF$，

$
  f(x) = sum_(i = 0)^d a_i x^i
$

== 多项式插值法（Deterministic Algorithm）

#algorithm(caption: [多项式插值], label: <polynomial-interpolation>)[
  #pseudocode-list[
    + 任意选择 $d + 1$ 个不同的数 $x_0, x_1, dots, x_d in F$
    + 计算多项式在这些点的值 $f(x_0), f(x_1), dots, f(x_d)$
    + *如果* 对于任意 $i$，$f(x_i) = 0$
      + 输出 $f equiv 0$
    + *否则*
      + 输出 $f equiv.not 0$
  ]
]

=== 正确性

#theorem(name: [代数学基本定理 (Fundamental Theorem of Algebra)])[
任何度数为 $d$ 的非零多项式 $f in FF[x]$ 最多有 $d$ 个根。
]<fundamental-theorem-of-algebra>

根据 @fundamental-theorem-of-algebra，如果 $f equiv.not 0$，那么 $f$ 最多有 $d$ 个根，所以不可能在 $d + 1$ 个不同的点处取值为零；如果 $f equiv 0$，那么 $f$ 在任意点处取值为零。

=== 复杂度

计算 $f(x_i)$ 的复杂度为 $O(d)$，总共需要计算 $d + 1$ 个点，所以总的时间复杂度为 $O(d^2)$。

== 多项式指纹（Randomized Algorithm）

#algorithm(caption: [多项式指纹], label: <polynomial-fingerprint>)[

#pseudocode-list[
  + 决定一个集合 $S subset F$。
  + 从 $S$ 中随机选择一个点 $r$。
  + 计算 $f(r)$。
  + *如果* $f(r) = 0$
    + 输出 $f equiv 0$
  + *否则*
    + 输出 $f equiv.not 0$
]
]<PIT>

=== 正确性

- 若事实上 $f equiv 0$

  则 $f(r) = 0$，不可能出错

- 实际上 $f equiv.not 0$

  当且仅当 $f(r) = 0$ 时出错

  考虑 $S$ 中可能为 $f$ 根的点的数量。
  
  根据 @fundamental-theorem-of-algebra，$f$ 在 $S$ 中至多有 $d$ 个根。因此，随机选择 $r$ 使得非零多项式 $f$ 在 $r$ 处为零的概率最多为 $d / abs(S)$。

  若取 $abs(S) = 2d$，则出错概率最多为 $1 / 2$。


=== 复杂度

计算 $f(r)$ 的复杂度为 $O(d)$，所以总的时间复杂度为 $O(d)$。


== 应用 - 通信复杂性

Alice 持有字符串 $a$，Bob 持有字符串 $b$，其中 $a, b in {0, 1}^n$；Alice 和 Bob 通过通信来判定 $a$ 和 $b$ 是否相等。

实际上就是求下面 EQ 函数

$
  "EQ" : {0, 1}^n times {0, 1}^n -> {0, 1} \

  "EQ"(a , b) = cases(
    1 #h(1em) & a = b,
    0 #h(1em) & a != b
  )
$

#fakepar

在这个场景下，我们关心的是 Alice 和 Bob 之间的通信复杂度，也就是他们需要交换多少 bits 的信息来完成这个任务。

=== 确定性算法

比较两个字符串的每一位。

通信复杂性：$n$ bits

#theorem(name: [Yao 1979])[
任何确定性通信协议解决 EQ 问题，在最坏情况下都至少需要通信 $n$ 比特。
]

=== 私有硬币模型（Naive）

#algorithm(caption:[Naive], label: <string-identity-private-coin-naive>)[

#pseudocode-list[
  + 定义 $f = sum_(i = 1)^(n - 1) a_i x^i$
  + 定义 $g = sum_(i = 1)^(n - 1) b_i x^i$
  + 确定集合 $S$
  + Bob 从 $S$ 中随机选择一个数 $r$，计算 $g(r)$
  + Bob 传输 $r, g(r)$ 给 Alice
  + Alice 计算 $f(r)$ 并判断是否 $f(r) = g(r)$
  + *如果* $f(r) = g(r)$
    + 输出 $a = b$
  + *否则*
    + 输出 $a != b$
]
]

==== 正确性

// 正确性：根据 PIT，错误概率为 $d / abs(S)$。

首先，度数为 $n$ 的多项式 $f - g equiv 0$ 当且仅当 $a_i = b_i$ 对于任意 $i$ 都成立，这等价于 $a = b$。

其次，根据 @polynomial-fingerprint，错误判断 $f equiv g$ 的概率最多为 $n / abs(S)$，令 $abs(S) = 2n$，则错误概率最多为 $1 / 2$。

==== 复杂度

通信复杂性：由于 $g(r)$ 的值最大可以达到 $r^n$，所以 $g(r)$ 的 bit 数为 $O(log r^n) = O(n log r) = O(n log n)$，比直接传输 $n$ 个 bits 的字符串还要差。

=== 私有硬币模型（Improved）

由于 @string-identity-private-coin-naive 的主要问题在于，多项式的值可能非常大，导致通信复杂度较高。我们可以通过选择一个足够大的素数 $p$ 来取模，从而保证多项式的值不会过大。

#algorithm(caption: [Improved], label: <string-identity-private-coin-improved>)[
  #pseudocode-list[
    + 取一个素数 $p$，$p in [n^2, 2n^2]$。
    + 定义 $f = sum_(i = 0)^(n - 1) a_i x^i mod p$ 
    + 定义 $g = sum_(i = 0)^(n - 1) b_i x^i mod p$
    + Bob 从 $[p]$ 中随机选择一个数 $r$，计算 $g(r)$
    + Bob 传输 $r, g(r)$ 给 Alice
    + Alice 计算 $f(r)$ 并判断是否 $f(r) = g(r)$
    + *如果* $f(r) = g(r)$
      + 输出 $a = b$
    + *否则*
      + 输出 $a != b$
  ]
]

==== 正确性

由于代数学基本定理在 $ZZ_p [x]$ 中仍然成立，所以错误判断 $f equiv g$ 的概率最多为 $n / p$，令 $p >= n^2$，则错误概率最多为 $1 / n$。

==== 复杂度

通信复杂度：由于 $f(r)$ 的值最大可以达到 $p$，所以 $f(r)$ 的 bit 数为 $O(log p) = O(log n^2) = O(log n)$。


=== 随机化算法（公共硬币模型）

#tips[Public Coin vs Private Coin][
  - 公共硬币模型（Public Coin Model）: Alice 和 Bob 共享一个随机数生成器，也就是说，假如他们同步抽取一个随机数，那么他们都能得到相同的结果。
  - 私有硬币模型（Private Coin Model）: Alice 和 Bob 各自拥有一个随机数生成器，他们抽取的随机数彼此独立。

  公共硬币模型下，问题的难度总是低于私有硬币模型。因为假如存在一个私有硬币模型下的协议可以解决某个问题，那么在公共硬币模型下，Alice 和 Bob 可以通过依次独立地从随机数生成器抽取随机数来模拟私有硬币模型下的随机数，从而模拟私有硬币模型下的协议。
]

#algorithm(caption: [Public Coin], label: <string-identity-public-coin>)[
  // Alice 和 Bob 共享一个随机数 $bm(r) in {0, 1}^n$。

  // 令 $f = xor.big_(i = 1)^(n - 1) a_i r^i$ 和 $g = xor.big_(i = 1)^(n - 1) b_i r^i$。

  // Bob 计算 $g(bm(r))$ 传输给 Alice，Alice 计算 $f(bm(r))$ 并判断是否 $f(bm(r)) = g(bm(r))$。

  #pseudocode-list[
    + Alice 和 Bob 同步从随机数生成器抽取一个随机数 $bm(r) in {0, 1}^n$
    + 定义 $f = xor.big_(i = 0)^(n - 1) a_i r^i$ 和 $g = xor.big_(i = 0)^(n - 1) b_i  r^i$
    + Bob 计算 $g(bm(r))$ 传输给 Alice
    + Alice 计算 $f(bm(r))$ 并判断是否 $f(bm(r)) = g(bm(r))$
    + *如果* $f(bm(r)) = g(bm(r))$
      + 输出 $a = b$
    + *否则*
      + 输出 $a != b$
  ]
]

==== 正确性

#proof[
  分两种情况，

- 事实上 $a = b$

  则 $f equiv g$，所以 $f(bm(r)) = g(bm(r))$，不可能出错

- 事实上 $a != b$

  即 $D subset [n]$，为 ${i : a_i != b_i}$，$|D| = k$。

  使用数学归纳法：

  / Hypothesis $H(k)$: \
  
    如果 $a$ 和 $b$ 在 $k$ 个位置上不同，那么 $Pr[f(bm(r)) = g(bm(r))] = 1 / 2$。
    
  / Base case $H(1)$: \
    
    记 $D = {i}$，由于 $r_i$ 有 $1 / 2$ 的概率为 $0$，$1 / 2$ 的概率为 $1$，而 $f(bm(r)) = g(bm(r))$ 仅当 $r_i = 0$ 时成立，所以 $Pr[f(bm(r)) = g(bm(r))] = 1 / 2$。
  / Inductive Steps $H(k - 1) -> H(k)$: \
  // $r_i_k$ 有 $1 / 2$ 为 $0$，$1 / 2$ 为 $1$。假如 $r_i_k = 0$，那么结果不变，仍然是 $1 / 2$ 的概率返回 $f equiv g$；假如 $r_i_k = 1$，那么结果取反，也是 $1 / 2$ 的概率返回 $f equiv g$；所以返回 $f equiv g = 1 / 2 (1 / 2 + 1 / 2) = 1 / 2$。
    
    记 $D = {i_1, i_2, dots, i_k}$，考虑 $r_(i_k)$，$r_(i_k)$ 有 $1 / 2$ 的概率为 $0$，$1 / 2$ 的概率为 $1$。

    如果 $r_(i_k) = 0$，那么 $f(bm(r)) = g(bm(r))$ 当且仅当 $xor.big_(i in D \\ {i_k}) a_i r^i = xor.big_(i in D \\ {i_k}) b_i r^i$，根据归纳假设 $H(k - 1)$，有 $Pr[f(bm(r)) = g(bm(r))] = 1 / 2$。

    如果 $r_(i_k) = 1$，那么 $f(bm(r)) = g(bm(r))$ 当且仅当 $xor.big_(i in D \\ {i_k}) a_i r^i + a_(i_k) = xor.big_(i in D \\ {i_k}) b_i r^i + b_(i_k)$，由于 $a_(i_k) != b_(i_k)$，所以等价于 $xor.big_(i in D \\ {i_k}) a_i r^i != xor.big_(i in D \\ {i_k}) b_i r^i$，根据归纳假设 $H(k - 1)$，有 $Pr[f(bm(r)) = g(bm(r))] = 1 / 2$。

    综上所述 $Pr[f(bm(r)) = g(bm(r))] = 1 / 2 (1 / 2 + 1 / 2) = 1 / 2$。
]

#remark[
  直观上理解，$xor.big$ 代表的是二进制表示中 $1$ 个数的奇偶性，由于是随意选择的，对奇偶性并没有偏好，因此概率为 $1 / 2$。
]

#remark[
  要想达到 $1/n$ 的错误概率，可以重复上述算法 $O(log n)$ 次，每次独立地选择一个随机数 $bm(r)$，如果所有次的结果都返回 $f equiv g$，则输出 $a = b$；否则输出 $a != b$。看上去这没有比 Private Coin 下的算法更优。

  但是假如只想要 $0.01$ 的错误概率，那么在 Private Coin 下仍然需要 $O(log n)$ 的通信复杂度，而在 Public Coin 下只需要 $O(1)$ 的通信复杂度。 
]

= 多元 PIT

给定一个度数为 $d$ 的 $n$ 元多项式 $f in FF[x_1, x_2, dots, x_n]$，判定是否 $f equiv 0$？


其中 $FF[x_1, x_2, dots, x_n]$ 表示域 $FF$ 上的 $n$ 元多项式环，度数为 $d$ 的 $n$ 元多项式即

$
  f(x_1, x_2, dots, x_n) = sum_(i_1, dots, i_n > 0 \ i_1 + dots + i_n <= d) a_(i_1, dots, i_n) x_1^(i_1) x_2^(i_2) dots x_n^(i_n).
$

#fakepar

使用确定性算法难以高效解决，假如可以，就会推导出

$
  "NEXP" != "P/poly" or \#"P" != "FP"
$

#tips[关于复杂度类的说明][
$
  "P" subset.eq "NP" subset.eq "PSPACE" subset.eq "EXPTIME" subset.eq "NEXPTIME" subset.eq "EXPSPACE"
$


P/poly 是多项式大小的布尔电路能够解决的问题的集合。

\#P 是 NP 问题中解决方案计数的问题的集合。

FP 是多项式时间内计算函数的集合。

更多复杂性问题见 #link("https://complexityzoo.net/Complexity_Zoo:N")[Complexity Zoo]。
]

== 随机化算法（Schwartz-Zippel 定理）

#algorithm(caption: [多元多项式指纹], label: <multivariate-polynomial-fingerprint>)[
  #pseudocode-list[
    + 决定一个集合 $S subset F$。
    + 从 $S$ 中随机选择 $r_1, r_2, dots, r_n$。
    + 计算 $f(r_1, r_2, dots, r_n)$。
    + *如果* $f(r_1, r_2, dots, r_n) = 0$
      + 输出 $f equiv 0$
    + *否则*
      + 输出 $f equiv.not 0$
  ]
]

=== 正确性

#theorem(name: [Schwartz-Zippel Theorem])[
  对于一个度数为 $d$ 阶 $n$ 元多项式 $f in FF[x_1, x_2, dots, x_n]$，$S subset FF$，如果 $r_1, r_2, dots, r_n$ 从 $S$ 中独立均匀随机抽取，那么

  $
    f equiv.not 0 => Pr[f(r_1, r_2, dots, r_n) = 0] <= d / abs(S)
  $ 
]

#proof[
  使用数学归纳法：

  / Hypothesis $H(n)$: \ 
  
    对于一个度数为 $d$ 的 $n$ 元项式 $f equiv.not 0 => Pr[f(r_1, r_2, dots, r_n) = 0] <= d / abs(S)$

  / Base Case $H(1)$: @fundamental-theorem-of-algebra 代数学基本定理
  
  / Inductive Steps $H(n - 1) -> H(n)$: \

    令 $k$ 为 $f$ 中 $x_n$ 的最高次幂，

    $
      f(x_1, x_2, dots, x_n) = sum_(i = 0)^k x_n^i f_i (x_1, x_2, dots, x_(n - 1))
    $

    #fakepar

    因为 $f equiv.not 0$，且多项式中确存在 $x_n^k$ 项，所以 $f_k equiv.not 0$。

    所以我们单独提取 $x_n^k f_k$ 的项，得到 

    $
      f(x_1, x_2, dots, x_n) = x_n^k f_k (x_1, x_2, dots, x_(n - 1)) + overline(f)(x_1, x_2, dots, x_(n - 1), x_n). 
    $
    
    #fakepar

    其中 $f_k$ 是度数为 $d - k$ 的多项式且只和前 $n - 1$ 个变量有关，$overline(f)$ 是度数不超过 $d - 1$ 的多项式。

    利用全概率公式，

    $
      & Pr[f(bm(r)) = 0] \
    = & Pr[f(bm(r)) = 0 | f_k (bm(r_[1..n-1])) = 0] dot #box(fill: rgb("aaaaff"), outset: 0.2em)[$Pr[f_k (bm(r_[1..n-1])) = 0]$] \
    + & #box(fill: rgb("ffaadd"), outset: 0.2em)[$Pr[f(bm(r)) = 0 | f_k (bm(r_[1..n-1])) != 0]$] dot Pr[f_k (bm(r_[1..n-1])) != 0].
    $

    #box(fill: rgb("aaaaff"), inset: 1em, width: 100%)[
        由于 $f_k$ 是 $d - k$ 阶的多项式，根据归纳假设 $H(n - 1)$，有 $Pr[f_k (bm(r_[1..n-1])) = 0] <= (d - k) / abs(S)$。
    ]
    
    #box(fill: rgb("ffaadd"), inset: 1em, width: 100%)[
      由于我们已知 $f_k (bm(r_[1..n-1])) != 0$，所以我们可以取

      $
        g_(bm(x)_[1..n-1]) (x_n) = sum_(i = 0)^k x_n^i f_i (bm(x)_[x_1..x_(n-1)]),
      $

      我们固定 $x_1, x_2, dots, x_(n - 1)$，将 $f_i (bm(x)_[1..n-1])$ 看作常数，那么此时 $g$ 变成单变量 $k$ 阶多项式，根据 @fundamental-theorem-of-algebra，$Pr[g(bm(r)) = 0] <= k / abs(S)$。因为 $f_k (bm(r_[1..n-1])) != 0$，在这种情况下，我们不再需要担心系数为 $0$ 造成的多项式为 $0$ 概率不满足 @fundamental-theorem-of-algebra 的情况。
    ]

    又因为所有概率都有上界 1，所以有

    $
      Pr[f(bm(r)) = 0] <= #box(fill: rgb("aaaaff"), outset: 0.2em)[$(d - k) \/ abs(S)$] +  #box(fill: rgb("ffaadd"), outset: 0.2em)[$k \/ abs(S)$] = d / abs(S).
    $

]

#fakepar

这就意味着，在任意“立方体” $S^n subset FF^n$ 中，非零多项式 $f$ 的根的数量最多为 $d dot.op abs(S)^(n - 1)$。

== 应用 - 判断二分图是否存在完美匹配
#problem[判断二分图是否存在完美匹配][
给一个二分图 

$
  G(U, V, E) : forall {u, v} in E, u in U, v in V
$

其中 $|U| = |V|$，判断是否存在一个双射 $f : U -> V$，使得对于任意 $u in U$，$(u, f(u)) in E$。
]

#tips[二分图完美匹配相关算法][
- 霍尔定理（判断存在）
  
  二分图存在完美匹配当且仅当对于任意 $S subset U$，$|N(S)| >= |S|$。

- 增广路算法（构造匹配）

  / 增广路: 始于未匹配的顶点，交替经过匹配边和非匹配边，终于未匹配的顶点

  / 增广路算法: 

    1. 遍历未匹配节点
    2. 从未匹配节点开始 DFS，找到增广路
    3. 更新匹配

- 匈牙利算法（有权重） $O(n^3)$

- Hopcroft-Karp 算法 $O(m sqrt(n))$
]


#definition(name: [Edmonds matrix])[
  $
    forall i, j in [n], A(i, j) = cases(
      x_(i j) #h(1em) & (u_i, v_j) in E,
      0 #h(1em) & "otherwise"
    )
  $

  即我们定义了 $n times n$ 个变量 $x_(i j)$，如果存在边 $(u_i, v_j)$，则 $A(i, j) = x_(i j)$；否则 $A(i, j) = 0$。
]

#theorem(name: [Edmonds])[
  二分图存在完美匹配当且仅当 $det(A) != 0$。
]

#tips[行列式][

#definition(name: [行列式])[
  $
    det(A) = sum_(sigma in S_n) "sgn"(sigma) product_(i = 1)^n A(i, sigma(i))
  $

  其中，
  - $S_n$ 是 $n$ 阶置换群，也就是 $n$ 个元素的全排列
  - $"sgn"(sigma)$ 即逆序对个数的奇偶性
  - $A(i, sigma(i))$ 是 $A$ 的第 $i$ 行第 $sigma(i)$ 列的元素

]
]

#fakepar

也就是说，Edmonds 矩阵的行列式是一个 $n$ 阶多项式。

对于一个 Edmonds 矩阵，我们发现 $product_(i = 1)^n A(i, sigma(i))$ 非零，对任意 $i$，$A(i, sigma(i))$ 都必须非零，也即 $(u_i, v_(sigma(i))) in E$。于是，一定可以构造一个双射 $f : U -> V$，使得对于任意 $u_i in U$，$(u_i, f(u_i)) in E$。

也即只要 $det(A) equiv.not 0$，就一定存在一个双射 $f : U -> V$，使得对于任意 $u_i in U$，$(u_i, f(u_i)) in E$。

利用 @multivariate-polynomial-fingerprint 可以判断 $det(A) equiv 0$，从而判断二分图是否存在完美匹配。


== 应用 - 判断有根树的同构

#problem[判断有根树的同构][

  给定两棵有根树 $T_1(V_1, E_1, r_1)$ 和 $T_2(V_2, E_2, r_2)$，假如存在双射 $f : V_1 -> V_2$，使得对于任意 $v, w in V_1$，

  $
    (v, w) in E_1 <=> (f(v), f(w)) in E_2
  $
  
  且 $r_1 mapsto r_2$，那么称 $T_1$ 和 $T_2$ 同构。
]

#tips[树同构问题相关算法][

- AHU 算法
  - 合法括号序列与树的一一对应
  - 树的同构是传递的
  - 在拼接所有子树的括号串时，按照括号串字典序排序
]

对于高度为 $h$ 的树，我们取变量 $x_1, x_2, dots, x_h$，然后为每个高度为 $k$ 的节点 $v$ （有 $m$ 个孩子，$V = {v_1, v_2, dots, v_m}$）定义多项式：

  $
    f_v = cases(
      x_k #h(1em) & m = 0,
      product_(i = 1)^(m) (x_k - f_v_i) #h(1em) & m > 0
    )    
  $


注意到，$f$ 的阶为子树中叶子节点的个数。

#lemma[
  两棵有根树同构当且仅当 $f_v equiv f_w$。
]

#proof[
  使用数学归纳法：

  / Hypothesis $H(k)$: \ 
    对于高度为 $k$ 的树，$f_v equiv f_w$ 当且仅当 $v$ 和 $w$ 为根的子树同构。
  / Base Case $h(1)$: 高度为 $1$ 的树只有一个节点，总是同构的。
  / Inductive Steps $and.big_(i < k) H(i) -> H(k)$: 
    - $==>$
      假设 $f_v equiv f_w$。

      由于树的高度为 $k$，所以 $f_v$ 和 $f_w$ 一定存在项 $x_k$。

      假如固定 $x_1, x_2, dots, x_(k - 1)$，则 $f_v (x_k) = product_(i = 1)^(m) (x_k - f_(v_i))$ 和 $f_w (x_k) = product_(i = 1)^(m) (x_k - f_(w_i))$，其中 $f_(v_i) , f_(w_i)$ 被固定，和 $x_k$ 无关。
      
      根据代数学基本定理，多项式的分解唯一。所以一定存在一个 $[m]$ 的排列 $pi$ 使得 $f_(v_i)  equiv f_(w_(pi(i)))$。

      // 由于子树的高度小于 $k$，根据归纳假设，对任意 $i$，都有$v_i$ 为根的子树和 $w_(pi(i))$ 为根的子树同构。也即存在一个双射 $phi_i: V_i -> W_(pi(i))$。

      现在利用归纳假设 $H(k - 1)$，以 $v_i$ 为根的子树和 $w_(pi(i))$ 为根的子树同构，那么存在一个双射 $phi_i: V_i -> W_(pi(i))$。

      那么，对于 $V$ 和 $W$，双射 $phi$ 定义为：

      $
        phi(u) = cases(
          w #h(1em) & u = v,
          w_(pi(i)) #h(1em) & u = v_i,
          phi_i (u) #h(1em) & u in V_i
        ).
      $

    - $<==$ 假设 $v$ 和 $w$ 为根的子树同构。

      则存在一个双射 $pi : [m] -> [m]$，使得对于任意 $i$，$v_i$ 为根的子树和 $w_(pi(i))$ 为根的子树同构。套用归纳假设 $H(k - 1)$，对于任意 $i$，$f_(v_i) equiv f_(w_(pi(i)))$。

        于是，

        $
          f_v (x_k) = product_(i = 1)^(m) (x_k - f_(v_i)(k)) = product_(i = 1)^(m) (x_k - f_(w_(pi(i)))(k)) = f_w (x_k).
        $      

        #fakepar
        所以 $f_v equiv f_w$。
]

= Fingerprint

#definition(name: [Fingerprint])[
  $"FING"()$ 是一个函数，使得

  - $X = Y => "FING"(X) = "FING"(Y)$
  - $Pr["FING"(X) = "FING"(Y) | X != Y]$ 很小

  并且 $"FING"(X)$ 的值应当易算、易存储。
]

== Checking Matrix Multiplication

#problem[Checking Matrix Multiplication][ 
  给定 $n times n$ 矩阵 $A, B, C$，判定 $A B = C$。
]

#fakepar

选择随机向量 $bm(r) in {0, 1}^n$。

计算 $A (B bm(r)) - C bm(r)$，判断是否为 $bm(0)$。

=== 正确性

- 当 $A B = C$ 时

  不可能出错

- 当 $A B != C$ 时

  记 $A B - C$ 为 $D$，
  $
    Pr[A B bm(r) = C bm(r)] = Pr[D bm(r) = bm(0)] 
  $

  #fakepar

  为了简便，我们可以只考虑结果中 $(D bm(r))_i$ 为 $0$ 的概率，这样的概率总是比整个为 $0$ 的概率大。

  也就是说，我们要求两个向量内积为 $0$ 的概率，并且 $D_i$ 已经固定。

  考虑 $bm(r)$ 的取值，有 $2^n$ 种。会使得 $chevron.l bm(D_i), bm(r) chevron.r$ 的值为 $0$ 的 $r$ 有多少种？我们不知道，但是一定不超过 $2^(n - 1)$。

  为什么？假如 $r_i$ 都随意取，那么敌手必然可以操纵 $D_i$，使得 $chevron.l bm(D_i), bm(r) chevron.r != 0$；只有保留 $bm(r)_j$ 以应对情况，才可能使得 $chevron.l bm(D_i), bm(r) chevron.r = 0$。

  所以，$Pr[D bm(r) = bm(0)] <= 1 / 2$。

== Polynomial Identity Testing

$
  "FING"(f) = f(bm(r)) "for uniform independent" r_1, r_2, dots, r_n in S.
$

这就是 @multivariate-polynomial-fingerprint。

== Communication Complexity

$
  "FING"(b) = sum_(i = 0)^(n - 1) b_i r^i "for uniform independent" r in S.
$

从指纹的角度来考虑，我们可以找到新的函数：

$
  "FING"(x) = x mod p "for uniform random prime" p in [k]
$

通信复杂度：$O(log k)$ bits

=== 正确性

- 当 $x = y$ 时

  不可能出错

- 当 $x != y$ 时

  问题变为，对于 $z = abs(a - b) != 0$，其中 $Pr[z mod p = 0]$ 的上界。也即 $p$ 是 $z$ 的因子的概率。

  由于 $z < 2^n$，所以 $z$ 的素因子最多有 $log z = n$ 个。 

  在 $[k]$ 中的素数有 $pi(k)$ 个，它的值如下。

  #theorem(name: [Prime Number Theory])[
    $
      pi(N) ~ N / (ln N) "as " N -> oo
    $
  ] 

  #fakepar

  所以，$Pr[z mod p = 0] <= n / pi(k) ~ n / (k / ln k) = (n ln k) / k$。

  取 $k = n^3$，此时出错的概率为 $(3n ln n) / (n^3) = (3 ln n) / n^2 = O(1 / n)$。 

=== 复杂度

通信复杂度：$O(log n)$ bits

== Pattern Matching

#problem[Pattern Matching][
  给定字符串 $bm(x) in {0, 1}^n$，和模式串 $bm(y) in {0, 1}^m$，判定 $bm(y)$ 是否在 $bm(x)$ 中出现。
]

#tips[字符串匹配相关算法][

- Naive 算法 $O(n m)$

- Knuth-Morris-Pratt 算法 $O(n + m)$

- 有限自动机算法：Aho-Corasick Algorithm
]

#algorithm(caption: [Karp-Rabin Algorithm])[
#pseudocode-list[
  + 选择一个随机素数 $p in [m n^3]$。
  + *for* $i = 1 -> n - m + 1$ *do*
    + *if* $bm(y) equiv bm(x[i..i + m - 1]) (mod p)$
      + 输出 $i$
  + 输出 “无匹配“
]
]

=== 正确性

对于一个匹配的串，必然 $bm(y) equiv bm(x[i..i + m - 1]) (mod p)$，不可能出错。

把一个非匹配的串判定为匹配的概率为：

$
  Pr[bm(y) equiv bm(x[i..i + m - 1]) (mod p)] <= (m ln(m n^3)) / (m n^3) = o(1 / n^2)
$

由于有 $n - m + 1$ 个子串，根据 Union Bound，

$
   & Pr["出错"] \
<= & Pr[exists i, bm(y) equiv bm(x[i..i + m - 1]) (mod p)] \
=  & Pr[or.big_(i = 1)^(n - m + 1) bm(y) equiv bm(x[i..i + m - 1]) (mod p)] \
<=  & (n - m + 1) o(1 / n^2) \
= & o(1 / n)
$

=== 复杂度

- 一次 Hash 计算：$O(m)$
- 总共 $n - m + 1$ 次 Hash 计算：$O(n m)$

但是，观察到每次 Hash 计算的结果和上一次仅仅差了 $2$ 项，那么我们可以利用这个性质，将 Hash 计算的复杂度降低到 $O(1)$。

$
  & "FING"(bm(x[i + 1, i + m])) \
= & (bm(x)_(i + m) + 2 (bm(x)[i, i + m - 1] - 2^(m - 1) bm(x)_i)) mod p \
= & (bm(x)_(i + m) + 2 ("FING"(bm(x)[i, i + m - 1]) - 2^(m - 1) bm(x)_i)) mod p
$

所以总的时间复杂度为 $O(n + m)$。

== Check Distinctness

#problem[Check Distinctness][
  给定 $n$ 个数 $x_1, x_2, dots, x_n in [n]$，判定每个数字是否恰好出现一次。

  给定两个多重集 $A = {a_1, dots, a_n}$ 和 $B = {b_1, dots, b_n}$，其中 $a_i, b_i in [n]$，判定 $A = B$。
]

$
"FING"(A) = product_(i = 1)^(n) (r - a_i) mod p \
"FING"(B) = product_(i = 1)^(n) (r - b_i) mod p
$

  其中 $p in [(n log n)^2 / 2, (n log n)^2]$ 是一个随机素数，$r in [p]$ 是一个随机数。


记 $f_A (x) = product_(i = 1)^(n) (x - a_i) mod p$，$f_B (x) = product_(i = 1)^(n) (x - b_i) mod p$。

=== 正确性

- 当 $A = B$ 时

  不可能出错

- 当 $A != B$ 时

  造成出错的原因有两种，一种是模 $p$ 意义下 $f_A equiv f_B$；另一种是恰好 $f_A (r) = f_B (r)$。

  为了分析方便，我们记 $p$ 的取值范围为 $[L, U]$

  - $f_A equiv f_B$

    考虑 $f_A - f_B$，已知在 $ZZ$ 上 $f_A equiv.not f_B$，那么必然存在其中一个常数 $c != 0$ 但是 $c mod p = 0$。

    $
      Pr[f_A equiv f_B] <= Pr[c mod p = 0] = (\# c "的素因数") / (\# p "取值范围内的素数") <= (n log n) / (U / (ln U) - L / (ln L))
    $ 

  - $f_A (r) = f_B (r)$

    根据 PIT，错误概率 $ <= n / L$。

  综上，总的错误概率 $ <= (n log n) / (U / (ln U) - L / (ln L)) + n / L$。 

  $
   (n log n) / (U / (ln U) - L / (ln L)) + n / L  = (n log n) / ((n log n)^2 / (2 ln n)) dot O(1) + n / ((n log n)^2) <= O(1 / n).
  $

  时间复杂度 $O(n)$，空间复杂度 $O(log p) = O(log n)$。

