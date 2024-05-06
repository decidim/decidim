# Decidim::Proposals

The Proposals module adds one of the main components of Decidim: allows users to contribute to a participatory process by creating proposals.

## Usage

Proposals will be available as a Component for a Participatory Process.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'decidim-proposals'
```

And then execute:

```bash
bundle
```

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
