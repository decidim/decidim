# Decidim Meetings GraphQL Mutations

This directory contains GraphQL mutations for the decidim-meetings module.

## WithdrawMeeting Mutation

The WithdrawMeeting mutation allows authenticated users to withdraw meetings they have authored.

### Files

- `withdraw_meeting_type.rb` - Main mutation implementation
- `withdraw_meeting_attributes.rb` - Input attributes object (currently empty as no additional params needed)
- `meeting_mutation_type.rb` - Mutation wrapper for a single meeting
- `meetings_mutation_type.rb` - Component-level mutation type for accessing meetings

### Usage

See the root-level `WITHDRAW_MEETING_MUTATION_EXAMPLE.md` for complete usage examples.

### Quick Example

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

### Authorization

- User must be authenticated
- User must be the author of the meeting
- Meeting must not be already withdrawn
- Meeting must not be in the past

### Command Used

This mutation uses the existing `Decidim::Meetings::WithdrawMeeting` command located at:
`decidim-meetings/app/commands/decidim/meetings/withdraw_meeting.rb`

### Tests

Tests are located at:
`decidim-meetings/spec/types/meeting_mutation_type_spec.rb`
