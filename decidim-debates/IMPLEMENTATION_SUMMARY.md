# UpdateDebate Mutation - Implementation Summary

## Overview
This implementation adds a GraphQL mutation to update debates in the Decidim platform. The implementation follows the established patterns from the ProposalAnswerType mutation.

## What Was Implemented

### 1. Mutation Structure
- **UpdateDebateAttributes** (`decidim-debates/lib/decidim/api/mutations/update_debate_attributes.rb`)
  - GraphQL input type defining the fields that can be updated
  - Fields: title, description, taxonomy_ids

- **UpdateDebateType** (`decidim-debates/lib/decidim/api/mutations/update_debate_type.rb`)
  - Main mutation class that handles the update logic
  - Uses the existing `UpdateDebate` command
  - Validates user permissions (must be debate author or admin)
  - Returns the updated debate object

- **DebateMutationType** (`decidim-debates/lib/decidim/api/mutations/debate_mutation_type.rb`)
  - Wrapper class for debate-level mutations
  - Exposes the update mutation as a field

- **DebatesMutationType** (`decidim-debates/lib/decidim/api/mutations/debates_mutation_type.rb`)
  - Component-level mutation type
  - Provides access to specific debates for mutation
  - Registered in the MutationRegistry for GraphQL schema integration

### 2. Integration
- Updated `decidim-debates/lib/decidim/debates/api.rb` to autoload the new mutation classes
- Updated `decidim-debates/lib/decidim/debates/engine.rb` to register the mutation in the global MutationRegistry

### 3. Testing
- Created comprehensive specs in `decidim-debates/spec/types/debate_mutation_type_spec.rb`
- Added shared examples in `decidim-debates/spec/shared/debate_mutation_examples.rb`
- Test coverage includes:
  - Admin user access
  - API user access
  - Regular user as debate author
  - Unauthorized users
  - Taxonomy updates

### 4. Documentation
- Complete usage guide in `decidim-debates/UPDATE_DEBATE_MUTATION.md`
- Includes:
  - Basic examples
  - Advanced examples with taxonomies
  - Variable usage
  - cURL examples
  - Error handling
  - Integration details

## How It Works

### GraphQL Query Path
```
mutation
  └─ component(id: COMPONENT_ID)
      └─ ... on Debates
          └─ debate(id: DEBATE_ID)
              └─ update(input: { attributes: {...} })
```

### Authorization Flow
1. User makes a mutation request
2. `authorized?` method checks if user has edit permission
3. Permission system validates:
   - Debate is not closed
   - User is the debate author OR user is admin/has proper permissions
4. If authorized, mutation proceeds; otherwise returns nil

### Update Flow
1. Mutation receives attributes (title, description, taxonomy_ids)
2. Fetches current values as defaults for any missing attributes
3. Converts taxonomy IDs to taxonomy objects
4. Creates a DebateForm with the parameters
5. Calls UpdateDebate command
6. Command validates the form
7. Command updates the debate using Decidim.traceability
8. Returns the updated debate object

## Key Design Decisions

1. **Optional Fields**: All input fields are optional. If not provided, the mutation uses existing values.
   - This allows partial updates (e.g., only changing the title)

2. **Authorization**: Uses the same permission checks as the web interface
   - Consistent with Decidim's permission system
   - Respects component and participatory space permissions

3. **Form Reuse**: Uses the existing DebateForm for validation
   - Ensures consistency between API and web interface
   - Reuses all existing validations (presence, etiquette, etc.)

4. **Command Reuse**: Uses the existing UpdateDebate command
   - Ensures all business logic is applied (events, traceability, etc.)
   - Maintains consistency across all update paths

5. **Error Handling**: Returns GraphQL::ExecutionError with descriptive messages
   - Form validation errors are combined and returned
   - Maintains GraphQL best practices

## Testing Locally

To test this mutation locally:

1. Start your Decidim instance with GraphiQL enabled
2. Navigate to the GraphiQL interface (usually at `/api/graphiql`)
3. Use the example queries from UPDATE_DEBATE_MUTATION.md
4. Make sure you have:
   - A valid API token or be logged in as a user
   - A debate component with debates
   - Permission to edit a debate (be the author)

## Comparison with ProposalAnswerType

This implementation closely follows the ProposalAnswerType pattern:

| Aspect | ProposalAnswerType | UpdateDebateType |
|--------|-------------------|------------------|
| Input Type | AnswerProposalAttributes | UpdateDebateAttributes |
| Command | Admin::AnswerProposal | UpdateDebate |
| Form | ProposalAnswerForm | DebateForm |
| Authorization | admin scope | public scope (author check) |
| Scope | Admin action | User action |

Key difference: ProposalAnswerType is an admin action, while UpdateDebateType is a user action (users can edit their own debates).

## Future Enhancements

Potential improvements for future PRs:

1. **Attachment Support**: Add support for updating attachments via the API
2. **Bulk Updates**: Add a mutation to update multiple debates at once
3. **Partial Translation Support**: Allow updating specific locale translations
4. **Close Debate**: Add a separate mutation for closing debates
5. **Debate Reactions**: Add mutations for liking/following debates

## Related Files

### Commands
- `decidim-debates/app/commands/decidim/debates/update_debate.rb`

### Forms
- `decidim-debates/app/forms/decidim/debates/debate_form.rb`

### Controllers
- `decidim-debates/app/controllers/decidim/debates/debates_controller.rb`

### Permissions
- `decidim-debates/app/permissions/decidim/debates/permissions.rb`

### Models
- `decidim-debates/app/models/decidim/debates/debate.rb`

## Migration Notes

No database migrations are required. This implementation only adds API access to existing functionality.

## Breaking Changes

None. This is purely additive functionality.
