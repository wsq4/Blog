#import "template.typ": *
#import "@preview/kouhu:0.2.0": kouhu

#show: doc => template("How to Proof Time and Space Lower Bound for LSH", doc, bibliography_src: "example.bib")

= Heading 1

#lorem(50)

== Heading 2

#lorem(100)

#lorem(50)

#lorem(120)

=== Heading 3

#lorem(150)

#lorem(200)

#figure(caption: "Example Table")[
  #table(
    columns: (auto,) * 4,
    table.header([*Name*], [*Age*], [*City*], [*Occupation*]),
    [*Alice*], [30], [New York], [Engineer],
    [*Bob*], [25], [Los Angeles], [Designer],
    [*Charlie*], [35], [Chicago], [Teacher],
  )
]

#show ref: set text(fill: blue)

#lorem(50)

#lorem(15)

#lorem(100)

= 一级标题

#kouhu(indices: (1,))

== 二级标题

#kouhu(indices: (2, 3))

=== 三级标题

#kouhu(indices: (4, 5, 6))

#figure(caption: "示例图片")[
  #image("./example.jpg", width: 60%)
]

==== 四级标题

#link("https://www.example.com")[一个链接]#kouhu(indices: (1,))

= Related Works

#lorem(5).slice(0, -1) @smith2020 #lorem(35) @garcia2022 #lorem(50) @knuth1984@lamport1994 #lorem(25)

= 相关工作

#kouhu(indices: (1,)).slice(0, 24) @gov2020 #kouhu(indices: (2,)).slice(0, 24) @liu2018 #kouhu(indices: (3,))

#kouhu(indices: (4,)).slice(0, 24) @zhang2019@zhang2019 #kouhu(indices: (5,))

= Math

#lorem(25).slice(0, -1) $E = m c^2$, #lorem(5).slice(0, -1) $F = m a$ #lorem(10).slice(0, -1) $a^2 + b^2 = c^2$ #lorem(15).slice(0, -1) $e^(i pi) + 1 = 0$.

$
  sum_(i=1)^n i = n(n+1)/2
$

#lorem(50)

#lorem(10).slice(0, -1) $binom(n, k) = n! / (k! (n-k)!)$ #lorem(15)

= Theorem Environments

#lorem(50)

#theorem(name: [#lorem(4).slice(0, -1)])[
  #lorem(50)
]

#proof[
  #lorem(50)

  #lorem(50)
]

#theorem(name: [#kouhu(indices: (1,)).slice(0, 15)])[
  #kouhu(indices: (1,))
]

= Text Styles

#smallcaps[
  #lorem(50)
]

#lorem(50)#emph[#lorem(50)]#lorem(50)

#lorem(50)#strong[#lorem(50)]#lorem(50)

#lorem(50)"#lorem(20)"#lorem(50)

= 字形

#strong[#kouhu(indices: (1,))]

#emph[#kouhu(indices: (2,))]

= 中English混排

#kouhu(indices: (1,)).slice(0, 3 * 8)#lorem(1).slice(0, -1)#kouhu(indices: (1,)).slice(3 * 8, 3 * 25) #lorem(1).slice(0, -1) #kouhu(indices: (1,)).slice(3 * 25, 3 * 40) #lorem(1).slice(0, -1) #kouhu(indices: (1,)).slice(3 * 40, 3 * 50) #lorem(1).slice(0, -1) #kouhu(indices: (1,)).slice(3 * 50, 3 * 100) #lorem(1).slice(0, -1) #kouhu(indices: (1,)).slice(3 * 100, 3 * 150) #lorem(1).slice(0, -1) #kouhu(indices: (1,)).slice(3 * 150, 3 * 200) #lorem(1).slice(0, -1) #kouhu(indices: (1,)).slice(3 * 200, 3 * 250) #lorem(1).slice(0, -1) #kouhu(indices: (1,)).slice(3 * 250, 3 * 300) #lorem(1).slice(0, -1) #kouhu(indices: (1,)).slice(3 * 300, 3 * 350) #lorem(1).slice(0, -1) #kouhu(indices: (1,)).slice(3 * 350, 3 * 400) #lorem(1).slice(0, -1) #kouhu(indices: (2,)).slice(0, 3 * 5) #lorem(1).slice(0, -1)。

#emph[
  #kouhu(indices: (1,)).slice(0, 3 * 8)#lorem(1).slice(0, -1)#kouhu(indices: (1,)).slice(3 * 8, 3 * 25) #lorem(1).slice(0, -1) #kouhu(indices: (1,)).slice(3 * 25, 3 * 40) #lorem(1).slice(0, -1) #kouhu(indices: (1,)).slice(3 * 40, 3 * 50) #lorem(1).slice(0, -1) #kouhu(indices: (1,)).slice(3 * 50, 3 * 100) #lorem(1).slice(0, -1) #kouhu(indices: (1,)).slice(3 * 100, 3 * 150) #lorem(1).slice(0, -1) #kouhu(indices: (1,)).slice(3 * 150, 3 * 200) #lorem(1).slice(0, -1) #kouhu(indices: (1,)).slice(3 * 200, 3 * 250) #lorem(1).slice(0, -1) #kouhu(indices: (1,)).slice(3 * 250, 3 * 300) #lorem(1).slice(0, -1) #kouhu(indices: (1,)).slice(3 * 300, 3 * 350) #lorem(1).slice(0, -1) #kouhu(indices: (1,)).slice(3 * 350, 3 * 400) #lorem(1).slice(0, -1) #kouhu(indices: (2,)).slice(0, 3 * 5) #lorem(1).slice(0, -1)。
]

= Pseudo Code


#algorithm(
  caption: "Two Sum Problem",
  pseudocode-list([
    - *Input*: An array of integers `arr` and an integer `target`.
    - *Output*: A boolean value indicating whether there are two distinct integers in `arr` that sum up to `target`.
    - *let* $S <- emptyset$
    - *for* each integer $x$ in `arr` *do*:
      - *if* $"target" - x$ is in $S$ *then*:
        - *return* true
      - *end if*
      - Add $x$ to $S$
    - *end for*
    - *return* false
  ]),
)

= Code Block

#codeblock(caption: "Example Code")[
  ```cpp
  #include <iostream>
  #include <vector>
  #include <unordered_set>

  int main() {
      std::vector<int> arr = {1, 2, 3, 4, 5};
      int target = 7;
      std::unordered_set<int> S;

      for (int x : arr) {
          if (S.count(target - x)) {
              std::cout << "True" << std::endl;
              return 0;
          }
          S.insert(x);
      }

      std::cout << "False" << std::endl;
      return 0;
  }
  ```
]

= Shapes

#rect(width: 100pt, height: 50pt)