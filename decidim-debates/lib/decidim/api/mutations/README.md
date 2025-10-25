# Decidim Debates API Mutations

This directory contains GraphQL mutations for the Decidim Debates module.

## Available Mutations

### CreateDebate

Creates a new debate in a debates component.

**Location:** `create_debate_type.rb`

**Usage:**
```graphql
mutation {
  createDebate(input: {
    componentId: "123",
    attributes: {
      title: "Debate Title",
      description: "Debate Description",
      taxonomyIds: ["101", "102"]
    }
  }) {
    id
    title { translation(locale: "en") }
  }
}
```

**See:** `../../CREATE_DEBATE_MUTATION.md` for complete documentation

## Architecture

### File Structure

- `create_debate_attributes.rb` - Input object defining debate attributes
- `create_debate_type.rb` - Main mutation implementation
- `debate_mutation_type.rb` - Individual debate mutation wrapper
- `debates_mutation_type.rb` - Component-level mutation type

### Pattern

These mutations follow the same pattern as the proposals module:
1. Input attributes defined as `BaseInputObject`
2. Mutation class extends `BaseMutation`
3. Authorization checks via `authorized?` method
4. Form validation using existing Decidim forms
5. Command execution using existing Decidim commands

## Testing

Tests are located in `../../spec/types/`:
- `create_debate_type_spec.rb` - Main mutation tests
- Shared examples in `../../spec/shared/debate_mutation_examples.rb`

Run tests with:
```bash
bundle exec rspec spec/types/create_debate_type_spec.rb
```

## Related Files

- Command: `../../app/commands/decidim/debates/create_debate.rb`
- Form: `../../app/forms/decidim/debates/debate_form.rb`
- Controller: `../../app/controllers/decidim/debates/debates_controller.rb`
