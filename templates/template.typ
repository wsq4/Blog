#let page_width = 800pt
#let dark = false

// Do Not Modify The First two lines. 

#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *

#import "@preview/lemmify:0.1.8": default-theorems, thm-numbering-heading
#let (
  definition,
  theorem,
  lemma,
  corollary,
  remark,
  proposition,
  example,
  proof,
  rules: thm-rules,
) = default-theorems("thm-group", lang: "en",  thm-numbering: thm-numbering-heading.with(max-heading-level: 1))

#import "@preview/lovelace:0.3.1": *

#let fakepar = context {
  let b = par[#box()]
  let t = measure(b + b)

  [
    #b
    #v(-t.height)
  ]
}

#let template(title, doc, appendix: none, bibliography_src: none) = [
  #import "@preview/equate:0.3.2": equate
  #show: equate.with(breakable: true)

  #import "@preview/frame-it:1.2.0": frame-style, styles
  #show: frame-style(styles.boxy)

  #set text(
    font: ((name: "Source Sans 3", covers: "latin-in-cjk"), "Source Han Sans SC", "Noto Color Emoji"),
    size: 18pt,
    weight: "regular",
    fill: if dark { white } else { black },
  )

  #set strong(delta: 200)
  #show strong: it => {
    underline(it, stroke: (dash: "dotted"))
  }

  #show smallcaps: set text(font: "Source Sans 3")

  #show emph: set text(font: (
    (name: "Source Sans 3", covers: "latin-in-cjk"),
    "LXGW WenKai",
    "Noto Color Emoji",
  ))

  #show raw: set text(font: (
    (name: "Cascadia Mono", covers: "latin-in-cjk"),
    "LXGW WenKai Mono",
    "Noto Color Emoji",
  ))

  #let eq_font_size = if page_width > 540pt { 18pt } else {
    page_width / 30
  }

  #show math.equation.where(block: true): set text(size: eq_font_size)

  #show math.equation: set text(font: "New Computer Modern Math")

  #show link: x => underline(text(fill: blue, x))

  #set par(leading: 0.8em, spacing: 1.2em, first-line-indent: 1.8em, justify: true)

  #show: codly-init.with()
  #let codly-languages = codly-languages
  #codly-languages.insert(
    "dockerfile", (name: "Dockerfile",               color: rgb("#2496ED"),  icon: emoji.whale)
  )
  #codly(languages: codly-languages, zebra-fill: if dark { rgb("#37474F") } else { rgb("#ECEFF1") },  display-name: false)

  #show heading: it => {
    it
    fakepar
  }

  #show math.equation.where(block: true): it=> {
    it
    fakepar
  }

  #show enum: set par(first-line-indent: 0em)
  #show list: set par(first-line-indent: 0em)

  #show list: it=> {
    it
    fakepar
  }

  #show enum: it=> {
    it
    fakepar
  }

  #show heading: set block(inset: (bottom: 0.2em))

  #set heading(numbering: "1.")

  #set page(
    width: page_width,
    height: 3600pt,
    margin: (
      top: 0.2em,
      bottom: 0.2em,
      left: 0.1cm,
      right: 0.1cm,
    ),
    // fill: if dark { rgb("#212121") } else { white },
    fill: none
  )

  #set cite(style: "alphanumeric")
  #show: thm-rules

  #set rect(stroke: if dark { white } else { black })
  #set circle(stroke: if dark { white} else { black })
  #set line(stroke: if dark { white } else { black })

  #set table.cell(inset: 0.5em)
  #set table(stroke: gray)

  #fakepar
  #doc

  #if bibliography_src != none {
    bibliography(bibliography_src)
  }

  #set heading(numbering: "A.1.")
  #counter(heading).update(0)

  #appendix
]

#import "@preview/frame-it:1.2.0": *
#import "@preview/cetz:0.4.2"

#let bm(s) = {
  math.bold(s)
}

#let algorithm(label: none, ..args) = {
  set text(font: ("Source Serif 4", "Source Han Serif SC"))
  show figure.caption: set text(font: ("Source Sans 3", "Source Han Serif SC"))
  [
    #figure(kind: "algorithm", supplement: [Algorithm], ..args) #label
  ]
}

#let codeblock(..args) = {
  set raw(theme: "Material-Theme.tmTheme")
  show raw.where(block: true): it => block(
    it,
    inset: 2em,
    fill: rgb("#263238"),
    radius: 0.5em,
  )

  figure(kind: "codeblock", supplement: [Code], ..args)
}
