# Decidim Debates API Mutations

This directory contains GraphQL mutations for the Decidim Debates module.

## Available Mutations

### CloseDebate

Closes a debate with conclusions.

**Files:**
- `close_debate_type.rb` - Main mutation implementation
- `close_debate_attributes.rb` - Input attributes definition
- `debate_mutation_type.rb` - Wrapper for debate-level mutations
- `debates_mutation_type.rb` - Component-level entry point

**Documentation:**
See [CLOSE_DEBATE_MUTATION.md](./CLOSE_DEBATE_MUTATION.md) for comprehensive usage examples.

**Quick Example:**
```graphql
mutation {
  debates(manifest: "debates", id: 1) {
    debate(id: "123") {
      close(input: {
        attributes: {
          conclusions: {
            en: "Debate conclusions here..."
          }
        }
      }) {
        id
        conclusions { translation(locale: "en") }
        closedAt
      }
    }
  }
}
```

## Testing

Run the mutation tests with:
```bash
bundle exec rspec decidim-debates/spec/types/debate_mutation_type_spec.rb
```

## Architecture

The mutations follow the same pattern as the existing proposals mutations:

1. **Input Attributes** (`*_attributes.rb`) - Define the input structure
2. **Mutation Type** (`*_type.rb`) - Implement the mutation logic
3. **Wrapper Type** (`*_mutation_type.rb`) - Group related mutations
4. **Entry Point** (`*s_mutation_type.rb`) - Component-level access

## Adding New Mutations

To add a new debate mutation:

1. Create input attributes in `*_attributes.rb`
2. Create mutation type in `*_type.rb`
3. Add field to `debate_mutation_type.rb`
4. Add autoload to `decidim-debates/lib/decidim/debates/api.rb`
5. Create comprehensive tests
6. Document with examples

## References

- Decidim API Documentation: https://docs.decidim.org/
- Proposals Mutations: `decidim-proposals/lib/decidim/api/mutations/`
