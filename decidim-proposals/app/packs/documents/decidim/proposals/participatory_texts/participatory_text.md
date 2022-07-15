<!-- markdown-lint-disable-file single-h1 -->

# Section title 1: grouping content

Participatory texts relay on the parsing of Markdown texts to produce a structured document.

Participatory texts are divided into 3 types of blocks:

- Section: produced by main headers (paragraphs starting with "# ")
- Subsection: produced by secondary headers (paragraphs starting more than one "#") until 6 levels.
- Article: produced by paragraphs and lists.

## Subsection title 1.1

Parsing of Markdown is strict.
This means that, for paragraphs and lists, all blocks should be separated by a blank line between them.
The first, second and this third paragraphs, for example, will be grouped into a single participatory text article.

This paragraph instead, will produce a single participatory text article.

This paragraph also, will produce a third participatory text article.

## Subsection title 1.2

Inside a paragraph list or a list, **bold text** is supported, *italics text* is supported, __underlined text__ is supported.
As explained [here](https://daringfireball.net/projects/markdown/syntax#em) Markdown treats asterisks (\*) and underscores (\_) as indicators of emphasis. Text wrapped with these characters will be wrapped with an HTML \<em> tag; double \*’s or \_’s will be wrapped with an HTML \<strong> tag. E.g., this input:

- *single asterisks*
- _single underscores_
- **double asterisks**
- __double underscores__

You can use the following reference when writing your documents: [https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet).

# Section title 2: lists

Lists will be parsed as one block:

- consensus by simple majority: when a, b, and c appear in the creation.
- consensus by enhanced majority: when a, b, c and also d appear in the creation.
- consensus by absolute majority: when x, y and z appear in the creation.
- consensus by imposing whatever the organization wants: to be used at will.
- consensus by ignoring whatever resulted from the previous consensus: to be used when organization don't like the results of another consensus system.

Ordered lists will be parsed too:

1. one
1. two
1. three
1. four
1. five

# Section title 3: images and links

A link to Decidim's web site uses [this format](https://decidim.org).

![Important image for Decidim](https://meta.decidim.org/assets/decidim/decidim-logo-1f39092fb3e41d23936dc8aeadd054e2119807dccf3c395de88637e4187f0a3f.svg)
