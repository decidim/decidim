# UpdateMeeting Mutation - Implementation Summary

## Overview
This implementation adds a GraphQL mutation to update meetings in Decidim via the API. The mutation follows the same pattern as the existing `ProposalAnswerType` mutation in decidim-proposals.

## Files Created

### 1. Mutation Files
- `decidim-meetings/lib/decidim/api/mutations/update_meeting_attributes.rb`
  - Input type defining all updateable meeting attributes
  - Based on `AnswerProposalAttributes` pattern

- `decidim-meetings/lib/decidim/api/mutations/update_meeting_type.rb`
  - Main mutation logic
  - Handles form creation, validation, and command execution
  - Based on `ProposalAnswerType` pattern

- `decidim-meetings/lib/decidim/api/mutations/meeting_mutation_type.rb`
  - Defines mutations available for a single meeting
  - Based on `ProposalMutationType` pattern

- `decidim-meetings/lib/decidim/api/mutations/meetings_mutation_type.rb`
  - Exposes mutations at the component level
  - Based on `ProposalsMutationType` pattern

### 2. Test Files
- `decidim-meetings/spec/types/update_meeting_type_spec.rb`
  - Main spec for the mutation
  - Tests different user types (author, admin, api_user, unauthorized)

- `decidim-meetings/spec/shared/update_meeting_mutation_examples.rb`
  - Shared examples for mutation behavior
  - Tests successful updates and validation errors

### 3. Documentation
- `decidim-meetings/lib/decidim/api/mutations/UPDATE_MEETING_USAGE.md`
  - Comprehensive usage guide with examples
  - Covers GraphQL, cURL, JavaScript, and Ruby clients
  - Documents all field options and error handling

- `decidim-meetings/lib/decidim/api/mutations/TESTING_GUIDE.md`
  - Quick reference for manual testing
  - Common test scenarios and troubleshooting

### 4. Configuration Files Modified
- `decidim-meetings/lib/decidim/meetings/api.rb`
  - Added autoload statements for new mutation classes

- `decidim-meetings/lib/decidim/meetings/engine.rb`
  - Registered `MeetingsMutationType` in the mutation registry

## Architecture

### Query Structure
```
participatoryProcess
  └── components
        └── meetings (MeetingsMutationType)
              └── meeting(id)
                    └── update(input) → Meeting
```

### Data Flow
1. Client sends mutation with meeting ID and attributes
2. `MeetingsMutationType` resolves the meeting by ID
3. `MeetingMutationType` provides the update mutation field
4. `UpdateMeetingType` receives attributes
5. Form is created with merged attributes (existing + updates)
6. `UpdateMeeting` command is called
7. Meeting is updated via traceability system
8. Updated meeting is returned

### Authorization
- Checks if user can `:update` the `:meeting`
- Authorized if:
  - User is the meeting author, OR
  - User is an admin, OR
  - User is an API user with proper scopes

## Key Design Decisions

### 1. Partial Updates
The mutation supports partial updates by merging provided attributes with existing values:
```ruby
form_params = {
  title: params[:title] || object.title,
  description: params[:description] || object.description,
  # ... etc
}
```

### 2. Form Validation
Uses the existing `MeetingForm` to ensure consistency with controller-based updates:
```ruby
form = Decidim::Meetings::MeetingForm.from_params(form_params)
  .with_context(
    current_component: object.component,
    current_user:,
    current_organization: current_user.organization
  )
```

### 3. Command Execution
Leverages the existing `UpdateMeeting` command:
```ruby
UpdateMeeting.call(form, object) do
  on(:ok) { |meeting| return meeting }
  on(:invalid) { return GraphQL::ExecutionError.new(errors) }
end
```

### 4. Traceability
Updates are automatically tracked via Decidim's traceability system (handled by UpdateMeeting command)

### 5. Notifications
Meeting followers are notified when important attributes change (start_time, end_time, address) - handled by UpdateMeeting command

## Comparison with ProposalAnswerType

| Aspect | ProposalAnswerType | UpdateMeetingType |
|--------|-------------------|-------------------|
| Base mutation | BaseMutation | BaseMutation |
| Authorization scope | `:admin` | No scope (author or admin) |
| Resource identifier | Proposal | Meeting |
| Form used | ProposalAnswerForm | MeetingForm |
| Command used | AnswerProposal | UpdateMeeting |
| Partial updates | Yes (with reverse_merge) | Yes (with || operator) |

## Testing

### Unit Tests
Run the mutation specs:
```bash
bundle exec rspec decidim-meetings/spec/types/update_meeting_type_spec.rb
```

### Integration Testing
See `TESTING_GUIDE.md` for manual testing procedures.

### Test Coverage
- ✓ Authorized users can update meetings
- ✓ Unauthorized users cannot update meetings
- ✓ Admins can update any meeting
- ✓ API users with proper scopes can update meetings
- ✓ Validation errors are properly returned
- ✓ Partial updates work correctly

## Usage Example

### Basic Update
```graphql
mutation UpdateMeeting {
  meetings {
    meeting(id: "123") {
      update(input: {
        attributes: {
          title: { en: "Updated Title" }
          description: { en: "Updated description" }
          startTime: "2025-12-01T14:00:00Z"
          endTime: "2025-12-01T16:00:00Z"
        }
      }) {
        id
        title { translation(locale: "en") }
        startTime
        endTime
      }
    }
  }
}
```

## Future Enhancements

Potential improvements for future iterations:
1. Add support for updating meeting services
2. Add support for updating meeting agenda
3. Add support for updating meeting attachments
4. Batch update operations for multiple meetings
5. Support for creating meetings via mutation (CreateMeeting mutation)

## References

### Decidim PRs Analyzed
- [PR #14996](https://github.com/decidim/decidim/pull/14996)
- [PR #14974](https://github.com/decidim/decidim/pull/14974)
- [PR #14911](https://github.com/decidim/decidim/pull/14911)
- [PR #14885](https://github.com/decidim/decidim/pull/14885)
- [PR #14881](https://github.com/decidim/decidim/pull/14881)

### Related Code
- `decidim-proposals/lib/decidim/api/mutations/proposal_answer_type.rb` - Pattern reference
- `decidim-proposals/app/controllers/decidim/proposals/admin/proposal_answers_controller.rb` - Controller pattern
- `decidim-meetings/app/controllers/decidim/meetings/meetings_controller.rb` - Meeting controller
- `decidim-meetings/app/commands/decidim/meetings/update_meeting.rb` - Update command
- `decidim-meetings/app/forms/decidim/meetings/meeting_form.rb` - Meeting form

## Maintenance Notes

### When Adding New Meeting Attributes
1. Add the attribute to `UpdateMeetingAttributes` input type
2. Add to the merge logic in `UpdateMeetingType#resolve`
3. Update the documentation
4. Add test cases

### When Changing Authorization
Modify the `authorized?` method in `UpdateMeetingType`

### When Changing Validation
Update the `MeetingForm` class - changes will automatically apply to the mutation

## Support

For questions or issues:
1. Check the documentation in `UPDATE_MEETING_USAGE.md`
2. Review test examples in `update_meeting_type_spec.rb`
3. Consult the Decidim API documentation
4. Review the implementation in `update_meeting_type.rb`
