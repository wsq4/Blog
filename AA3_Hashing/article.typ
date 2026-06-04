#import "template.typ": *
#import "@preview/frame-it:2.0.0": *

#let problem = frame("问题", green)
#let tips = frame("提示", blue)

#show figure.where(kind: "frame"): set par(first-line-indent: 0em)
#show figure.where(kind: "frame"): set block(breakable: true)

#show: doc => template("2025S 高级算法 - Hashing", doc, bibliography_src: none)

一个长度为 $k$ 的 Path 是 $x,1,b,2,c,3, dots $，有 $k$ 个元素，每个元素是一个 key 和一个 slot。

已知，一个长度为 $k$ 的 Path 存在的概率是 $m^(- 2 k - 1)$。

长度为 $k$ 的 Path 属于 $([n] times [m])^k$，即一个 key 有 $n$ 个选择，一个 slot 有 $m$ 个选择，一项有 $n m$ 个选择，$k$ 项有 $(n m)^k$ 个选择。

所以，长度为 $k$ 的 Path 的数量不超过 $(n m)^k$。每个 Path 在图上存在的概率是 $m^(- 2 k - 1)$，所以

$
  Pr["len"("path") >= k] <= (n m)^k m^(- 2 k - 1) <= n^k / m^(k + 1) = exp(-Omega(k)).
$

对于一个长度为 $k$ 的 Circle，一定存在一个长度为 $k - 1$ 的 Path，所以

$
  Pr["len"("circle") >= k] <= Pr["len"("path") >= k - 1] <= exp(-Omega(k)).
$

根据期望的定义，

$
  EE["len"("path")] &= sum_(k = 0)^(oo) Pr["len"("path") = k] dot.op k\
  &<= sum_(k >= 1) Pr["len"("path") >= k] dot.op k\
  &<= sum_(k >= 1) exp(-Omega(k)) dot.op k\
  &= dif / (dif x) sum_(k >= 1) integral k x^(-Omega(k)) dif x bar_(x=e) \
  &= dif / (dif x) sum_(k >= 1) x^(-Omega(k)) bar_(x=e) \
  &= O(1). 
 $