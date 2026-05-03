# decidim-proposals

The Proposals module adds one of the main components of Decidim: allows users to contribute to a participatory space by creating proposals.

## Usage

Proposals will be available as a Component for a Participatory Space.

## Installation

This is on the default Decidim installation so you should not change anything to use this component.

## Global Search

This module includes the following models to Decidim's Global Search:

- `Proposals`

## Participatory Texts

Participatory texts persist each section of the document in a Proposal.

When importing participatory texts all formats are first transformed into Markdown and is the markdown that is parsed and processed to generate the corresponding Proposals.

When processing participatory text documents three kinds of sections are taken into account.

- Section: each "Title 1" in the document becomes a section.
- Subsection: the rest of the titles become subsections.
- Article: paragraphs become articles.

## Contributing

See [Decidim](https://github.com/decidim/decidim).

## License

See [Decidim](https://github.com/decidim/decidim).
