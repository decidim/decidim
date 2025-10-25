# CloseDebate Mutation - Implementation Summary

## Overview

This PR successfully implements a GraphQL mutation for closing debates in the Decidim platform, following the established patterns from the Proposals module.

## What Was Implemented

### 1. Core Mutation Files

#### Input Attributes (`close_debate_attributes.rb`)
- Defines the input structure for the mutation
- Accepts `conclusions` as JSON (supports multilingual content)
- Located at: `decidim-debates/lib/decidim/api/mutations/close_debate_attributes.rb`

#### Main Mutation (`close_debate_type.rb`)
- Implements the core mutation logic
- Handles locale resolution for multilingual conclusions
- Validates user permissions via `closeable_by?` method
- Uses existing `CloseDebateForm` and `CloseDebate` command
- Located at: `decidim-debates/lib/decidim/api/mutations/close_debate_type.rb`

#### Mutation Wrapper (`debate_mutation_type.rb`)
- Groups debate-level mutations
- Provides the `close` field
- Located at: `decidim-debates/lib/decidim/api/mutations/debate_mutation_type.rb`

#### Entry Point (`debates_mutation_type.rb`)
- Component-level entry point
- Provides access to debates by ID
- Located at: `decidim-debates/lib/decidim/api/mutations/debates_mutation_type.rb`

### 2. Tests

#### Main Test File (`debate_mutation_type_spec.rb`)
- Tests admin user scenarios
- Tests debate author scenarios
- Tests API user scenarios
- Tests unauthorized user scenarios
- Located at: `decidim-debates/spec/types/debate_mutation_type_spec.rb`

#### Shared Examples (`close_debate_mutation_examples.rb`)
- Reusable test scenarios
- Tests successful closure
- Tests validation errors
- Located at: `decidim-debates/spec/shared/close_debate_mutation_examples.rb`

### 3. Documentation

#### Comprehensive Guide (`CLOSE_DEBATE_MUTATION.md`)
- Full API documentation
- Examples in multiple programming languages:
  - GraphQL queries
  - JavaScript/TypeScript (Apollo Client)
  - Ruby (Net::HTTP)
  - Python (requests)
  - cURL
- Validation rules and error handling
- Located at: `decidim-debates/lib/decidim/api/mutations/CLOSE_DEBATE_MUTATION.md`

#### Quick Start Guide (`QUICK_START.md`)
- Quick reference for common use cases
- Troubleshooting guide
- HTTP request examples
- Located at: `decidim-debates/lib/decidim/api/mutations/QUICK_START.md`

#### Mutations README (`README.md`)
- Architecture overview
- Directory structure explanation
- How to add new mutations
- Located at: `decidim-debates/lib/decidim/api/mutations/README.md`

### 4. Integration

#### API Registration (`api.rb`)
- Added autoload statements for all new mutation types
- Located at: `decidim-debates/lib/decidim/debates/api.rb`

#### Component Registration (`component.rb`)
- Registered `mutation_type` for debates component
- Located at: `decidim-debates/lib/decidim/debates/component.rb`

#### Main README Update (`README.md`)
- Added GraphQL API section
- Links to mutation documentation
- Example usage
- Located at: `decidim-debates/README.md`

## How to Use the Mutation

### Basic GraphQL Query

```graphql
mutation CloseDebate {
  debates(manifest: "debates", id: 1) {
    debate(id: "123") {
      close(input: {
        attributes: {
          conclusions: {
            en: "After comprehensive discussion, we have reached the following conclusions..."
          }
        }
      }) {
        id
        title {
          translation(locale: "en")
        }
        conclusions {
          translation(locale: "en")
        }
        closedAt
      }
    }
  }
}
```

### With JavaScript (Apollo Client)

```javascript
import { gql, useMutation } from '@apollo/client';

const CLOSE_DEBATE = gql`
  mutation CloseDebate($componentId: ID!, $debateId: ID!, $conclusions: JSON!) {
    debates(manifest: "debates", id: $componentId) {
      debate(id: $debateId) {
        close(input: { attributes: { conclusions: $conclusions } }) {
          id
          closedAt
        }
      }
    }
  }
`;

// Usage in a component
const [closeDebate] = useMutation(CLOSE_DEBATE);
await closeDebate({
  variables: {
    componentId: "1",
    debateId: "123",
    conclusions: { en: "Conclusions here..." }
  }
});
```

### With cURL

```bash
curl -X POST https://your-instance.org/api \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "query": "mutation($componentId: ID!, $debateId: ID!, $conclusions: JSON!) { debates(manifest: \"debates\", id: $componentId) { debate(id: $debateId) { close(input: { attributes: { conclusions: $conclusions } }) { id closedAt } } } }",
    "variables": {
      "componentId": "1",
      "debateId": "123",
      "conclusions": { "en": "Conclusions here..." }
    }
  }'
```

## Authorization

The mutation requires the user to have permission to close the debate. This is granted to:
- **Debate authors** - Users who created the debate
- **Administrators** - Platform administrators
- **API users** - With appropriate permissions configured

Authorization is checked using the existing `closeable_by?(user)` method on the Debate model.

## Validation

The mutation validates:
1. **Conclusions presence** - Cannot be empty
2. **Conclusions length** - Between 10 and 10,000 characters
3. **User authorization** - Must have permission to close
4. **Debate existence** - Debate must exist and not be hidden

## Architecture

The implementation follows Decidim's established patterns:

```
debates_mutation_type.rb (Component level)
    └── debate_mutation_type.rb (Resource level)
            └── close_debate_type.rb (Action level)
                    ├── close_debate_attributes.rb (Input)
                    ├── CloseDebateForm (Validation)
                    └── CloseDebate (Command)
```

## Testing

Run the tests with:

```bash
bundle exec rspec decidim-debates/spec/types/debate_mutation_type_spec.rb
```

Test coverage includes:
- ✅ Admin users closing debates
- ✅ Debate authors closing their debates
- ✅ API users with permissions
- ✅ Unauthorized users being rejected
- ✅ Validation errors for invalid input
- ✅ Successful closure with multilingual conclusions

## Quality Checks

### Code Review
✅ Extracted locale resolution logic into a private method with proper error handling
✅ Improved documentation with contextual references
✅ All feedback addressed

### Security
✅ CodeQL security scan passed
✅ No vulnerabilities detected
✅ Proper authorization checks in place

## File Summary

### Created Files (10)
1. `decidim-debates/lib/decidim/api/mutations/close_debate_attributes.rb`
2. `decidim-debates/lib/decidim/api/mutations/close_debate_type.rb`
3. `decidim-debates/lib/decidim/api/mutations/debate_mutation_type.rb`
4. `decidim-debates/lib/decidim/api/mutations/debates_mutation_type.rb`
5. `decidim-debates/lib/decidim/api/mutations/CLOSE_DEBATE_MUTATION.md`
6. `decidim-debates/lib/decidim/api/mutations/QUICK_START.md`
7. `decidim-debates/lib/decidim/api/mutations/README.md`
8. `decidim-debates/spec/types/debate_mutation_type_spec.rb`
9. `decidim-debates/spec/shared/close_debate_mutation_examples.rb`
10. `decidim-debates/lib/decidim/api/mutations/IMPLEMENTATION_SUMMARY.md` (this file)

### Modified Files (3)
1. `decidim-debates/lib/decidim/debates/api.rb`
2. `decidim-debates/lib/decidim/debates/component.rb`
3. `decidim-debates/README.md`

## References

This implementation is based on:
- **ProposalAnswer mutation** in `decidim-proposals/lib/decidim/api/mutations/`
- **CloseDebate controller** in `decidim-debates/app/controllers/decidim/debates/debates_controller.rb`
- **CloseDebate command** in `decidim-debates/app/commands/decidim/debates/close_debate.rb`

Inspired by Decidim PRs:
- #14996 - Mutation patterns for component actions
- #14974 - GraphQL API authorization mechanisms
- #14911 - Mutation input handling
- #14885 - API types and mutations framework
- #14881 - Mutation error handling

## Next Steps

The implementation is complete and ready for use. To integrate:

1. **Merge the PR** - Merge `feature/close-debate-mutation` branch
2. **Deploy** - Deploy to your Decidim instance
3. **Test** - Test the mutation with your API clients
4. **Document** - Share the documentation with your API consumers

## Support

For questions or issues:
- See `QUICK_START.md` for common use cases
- See `CLOSE_DEBATE_MUTATION.md` for comprehensive documentation
- Check the test files for implementation examples
- Review the existing debates controller for business logic

---

**Implementation completed**: October 25, 2024
**Branch**: `feature/close-debate-mutation`
**Status**: ✅ Ready for review and merge
