# decidim-meetings

The Meetings module adds meeting to any participatory space. It adds a CRUD engine to the admin and public view scoped inside the participatory space.

## Usage

Meetings will be available as a Component for a Participatory Space.

## GraphQL API

This module provides GraphQL mutations for meeting management:

### WithdrawMeeting Mutation

Allows authenticated users to withdraw meetings they have authored.

For complete usage examples, see the root-level `WITHDRAW_MEETING_MUTATION_EXAMPLE.md` file.

Quick example:

```graphql
mutation WithdrawMeeting($componentId: ID!, $meetingId: ID!) {
  meetings(id: $componentId) {
    meeting(id: $meetingId) {
      withdraw(input: { attributes: {} }) {
        id
        withdrawn
        withdrawnAt
      }
    }
  }
}
```

See `lib/decidim/api/mutations/README.md` for more details about the mutations.

## Installation

This is on the default Decidim installation so you should not change anything to use this component.

## Global Search

This module includes the following models to Decidim's Global Search:

- `Meetings`

## Contributing

See [Decidim](https://github.com/decidim/decidim).

## License

See [Decidim](https://github.com/decidim/decidim).
