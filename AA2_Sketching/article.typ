#import "template.typ": *
#import "@preview/frame-it:2.0.0": *

#let problem = frame("问题", green)
#let tips = frame("提示", blue)

#show figure.where(kind: "frame"): set par(first-line-indent: 0em)
#show figure.where(kind: "frame"): set block(breakable: true)

#show: doc => template("2025S 高级算法 - Sketching", doc, bibliography_src: "ref.bib")

#let Var = math.op(math.bold("Var"))
#let Cov = math.op(math.bold("Cov"))

= Counting

#problem[计数器][
维护一个计数器 $n$，支持以下操作：
- *初始化*：$n <- 0$
- *增加*：$n <- n + 1$
- *查询*：返回 $n$ 的当前值
]

直接存储 $n$ 的值需要 $O(log n)$ 位空间。我们希望使用更少的空间来近似地维护计数器的值。

== Morris Counter

Morris Counter 维护一个整数 $X$，初始值为 $0$。对于操作：
- *增加*：以概率 $2^{-X}$，$X <- X + 1$；以概率 $1 - 2^{-X}$，$X$ 不变。
- *查询*：返回 $hat(n) = 2^X - 1$ 

== 无偏性

使用数学归纳法，

/ Hypothesis H(n): \
  在执行 $n$ 次增加操作后，$E[2^X] = n + 1$。
/ Base case H(0): \
  初始时 $X=0$，$E[2^X] = 1$，满足。
/ Inductive steps H(n-1) => H(n):\
  $
    &EE[2^(X_n)] \
    =& sum_(j) Pr[X_(n-1) = j] dot.op EE[2^(X_n)| X_(n - 1) = j] \
    =& sum_(j) Pr[X_(n-1) = j] dot.op (Pr[X_n = X_(n - 1)+ 1] dot.op 2^(j + 1) + Pr[X_n = X_(n - 1)] dot.op 2^j) \
    =& sum_(j) Pr[X_(n-1) = j] dot.op ( 2^j dot.op (1 - 2^(-j)) + 2^(j + 1) dot.op 2^(-j))) \
    =& sum_(j) Pr[X_(n-1) = j] dot.op (2^j + 1) \
    =& E[2^(X_(n-1))] + 1 \
    =& n + 1.
  $

所以 $E[hat(n)] = n$，Morris Counter 是无偏的。

== 空间复杂度

存储变量 $X$ 需要 $O(log X)$ 位空间。

利用 Jensen 不等式，$2^(E[X]) <= E[2^X] = n + 1$，所以 $E[X] <= log(n + 1)$。再用一次 Jensen 不等式，$EE[log X] <= log(E[X]) <= log(log(n + 1))$，所以 $E[log X] = O(log log n)$。因此 Morris Counter 的空间复杂度为 $O(log log n)$。

利用 Markov 不等式，$Pr[X >= log^2 n] <= E[X] / (log^2 n) = O(1 / (log n))$，所以 Morris Counter 以高概率使用 $O(log log n)$ 位空间。

#tips[Markov 不等式][
  Markov 不等式：对于任意非负随机变量 $X$ 和 $t > 0$，有 
  
  $
    Pr[X >= t] <= EE[X] / t.
  $

  #proof[
    $
      EE[X] & = EE[X|X >= t] dot.op Pr[X >= t] + EE[X|X < t] dot.op Pr[X < t] \
      & >= t dot.op Pr[X >= t] + 0 dot.op Pr[X < t] \
      & = t dot.op Pr[X >= t].
    $
  ]
]

#tips[Jensen 不等式][
  对于任意随机变量 $X$ 和“凸”函数 $f$，
  $
    f(EE[X]) <= EE[f(X)].
  $

  其中，函数 $f$ 是凸的，意味着对于任意 $x, y$ 和 $lambda in [0, 1]$，有

  $
    f(lambda x + (1 - lambda) y) <= lambda f(x) + (1 - lambda) f(y),  
  $

  即 $f[x..y]$ 的图线在 $(x, f(x))$ 和 $(y, f(y))$ 两点之间的线段下方；如果 $f$ 二阶可导，则 $f$ 是凸的当且仅当 $f''(x) >= 0$。
]

== 方差分析

使用数学归纳法。

/ Hypothesis H(n): \
  在执行 $n$ 次增加操作后，$Var[2^(X_n)] = (n(n - 1)) / 2$。

/ Base case H(0): \
  初始时 $X=0$，$Var[2^(X_0)] = 0$，满足。

/ Inductive steps H(n-1) => H(n):\

  $
    & Var[2^(X_n)] \
  = & EE[2^(2X_n)] - EE[2^(X_n)]^2 \
  = & EE[2^(-X_(n - 1)) dot 2^(2(X_(n - 1) + 1)) + (1 - 2^(-X_(n - 1))) dot 2^(2X_(n - 1))] - (n + 1)^2 \
  = & EE[2^(2 X_(n - 1)) + 3 dot.op 2^(X_(n - 1))] - (n + 1)^2 \
  = & EE[2^(2 X_(n - 1))] - n^2 + n^2 + 3 n - (n + 1)^2 \
  = & Var[2^(X_(n - 1))] + n - 1 \
  = & ((n - 2)(n - 1)) / 2 + (2(n - 1)) / 2 \
  = & (n(n - 1)) / 2.
  $

所以 $Var[hat(n)] = Var[2^X] = (n(n - 1)) / 2$。


#tips[Chebyshev 不等式][
 Chebyshev 不等式：对于任意随机变量 $X$ 和 $t > 0$，有 

 $
   Pr[abs(X - EE[X]) >= t] <= Var[X] / t^2.
 $

  #proof[
    令 $Y = (X - EE[X])^2$，则 $Y >= 0$ 且 $EE[Y] = Var[X]$。

    $
      Pr[abs(X - EE[X]) >= t] & = Pr[Y >= t^2] \
      & <= EE[Y] / t^2 \
      & = Var[X] / t^2.
    $
  ]
]

利用 Chebyshev 不等式，

$
  Pr[abs(hat(n) - n) >= epsilon n] <= (Var[hat(n)]) / (epsilon^2 n^2) <= 1 / (2 epsilon).
$

没什么用！

== Apply Mean Trick ( Morris Counter+ )

维护 $k$ 个独立的 Morris Counter $X_1, X_2, ..., X_k$，每个独立地维护一个计数器。对于查询操作，返回 $hat(n) = sum_(i=1)^k (2^(X_i) - 1) / k$。

#tips[线性方差][
  对于变量 $X, Y$ 以及常数 $a$，有

  - $Var[a] = 0$
  - $Var[X + a] = Var[X]$
  - $Var[a X] = a^2 Var[X]$
  - $Var[X + Y] = Var[X] + Var[Y] + 2 Cov[X, Y]$，其中当 $X$ 和 $Y$ 独立时，$Cov[X, Y] = 0$。
]

由于 $X_1, X_2, ..., X_k$ 独立，所以

$
  Var[hat(n)] & = Var[sum_(i=1)^k (2^(X_i) - 1) / k] \
  & = sum_(i=1)^k Var[(2^(X_i) - 1) / k] \
  & = sum_(i=1)^k (1 / k^2) Var[2^(X_i)] \
  & = (n(n - 1)) / (2 k).
$

所以 $Pr[abs(hat(n) - n) >= epsilon n] <= 1 / (2 k epsilon^2)$。令 $k = ceil(1 / (2 delta epsilon^2))$，则 $Pr[abs(hat(n) - n) >= epsilon n] <= delta$。

此时，每个 Morris Counter 需要 $O(log log n)$ 位空间，所以总空间复杂度为 $O((log log n) / (delta epsilon^2))$。

== Apply Median Trick

维护 $l$ 个独立的 Morris Counter+ $hat(n)_1, hat(n)_2, ..., hat(n)_l$，每个独立地维护一个计数器。对于查询操作，返回 $hat(n) = "median"(hat(n)_1, hat(n)_2, ..., hat(n)_l)$，取 $delta = 1 / 3$。

仅当一半以上的 $hat(n)_i$ 满足 $abs(hat(n)_i - n) >= epsilon n$ 时，才有 $abs(hat(n) - n) >= epsilon n$。

根据 Chernoff Bound，

$
  Pr[abs(hat(n) - n) >= epsilon n] & <= Pr[sum_(i=1)^l "1"(abs(hat(n)_i - n) >= epsilon n) >= l / 2] \
  & = Pr[sum_(i=1)^l "1"(abs(hat(n)_i - n) >= epsilon n) - l / 3 >= l / 6] \
  & <= exp(-2 (l / 6)^2 / l) \
  & = exp(-l / 18). 
$

#tips[Chernoff Bound][
  Chernoff Bound：对于独立的 Bernoulli 随机变量 $X_1, X_2, ..., X_n$，令 $X = sum_(i=1)^n X_i$ 和 $mu = E[X]$，则对于任意 $t > 0$，有

  $
    Pr[X >= (1 + t) mu] <= exp(-(t^2 mu) / (2 + t)),
  $

  $
    Pr[X <= (1 - t) mu] <= exp(-(t^2 mu) / 2).
  $
]

所以 $l = ceil(18 log(1 / delta))$ 即可。

此时，每个 Morris Counter+ 需要 $O((3 log log n) / (epsilon^2))$ 位空间，所以总空间复杂度为 $O(log log n dot.op log(1 / delta) dot.op 1/ (epsilon^2))$。

== $1 + alpha$ Counter

维护计数器 $X$，初始值为 $0$。对于操作：

- *增加*：以概率 $1 / (1 + alpha)^(X)$，$X <- X + 1$；以概率 $1 - 1 / (1 + alpha)^(X)$，$X$ 不变。
- *查询*：返回 $hat(n) = ((1 + alpha)^X - 1)/alpha$。

令 $alpha = epsilon^2 delta$。

空间复杂度为

- $O(log log n + log(1/epsilon) + log(1 / delta))$ @flajolet_approximate_1985
- $O(log log n + log(1/epsilon) + log log(1 / delta))$ @nelson_optimal_2022

= Distict Elements （0-frequency moments）

#problem[不同元素数量][
  
]