# decidim-debates

The Debates module adds debate to any participatory space. It adds a CRUD engine to the admin and public view scoped inside the participatory space.

## Usage

Debates will be available as a Component for any Participatory Space.

## Installation

This is on the default Decidim installation so you should not change anything to use this component.

## GraphQL API

The Debates module provides GraphQL mutations for programmatic interaction:

### CloseDebate Mutation

Close a debate with conclusions via the GraphQL API.

**Quick Start**: See [`lib/decidim/api/mutations/QUICK_START.md`](lib/decidim/api/mutations/QUICK_START.md)

**Full Documentation**: See [`lib/decidim/api/mutations/CLOSE_DEBATE_MUTATION.md`](lib/decidim/api/mutations/CLOSE_DEBATE_MUTATION.md)

**Example**:
```graphql
mutation {
  debates(manifest: "debates", id: 1) {
    debate(id: "123") {
      close(input: {
        attributes: {
          conclusions: { en: "Debate conclusions..." }
        }
      }) {
        id
        closedAt
      }
    }
  }
}
```

## Contributing

See [Decidim](https://github.com/decidim/decidim).

## License

See [Decidim](https://github.com/decidim/decidim).
