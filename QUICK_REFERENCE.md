# Quick Reference - CreateDebate Mutation

## Quick Start

```graphql
mutation {
  createDebate(input: {
    componentId: "YOUR_COMPONENT_ID",
    attributes: {
      title: "Your Debate Title",
      description: "Your debate description",
      taxonomyIds: ["taxonomy_id_1", "taxonomy_id_2"]  # Optional
    }
  }) {
    id
    title { translation(locale: "en") }
    description { translation(locale: "en") }
  }
}
```

## Authentication

Required scopes: `api:read`, `api:write`

```bash
Authorization: Bearer YOUR_ACCESS_TOKEN
```

## Files Overview

- **Implementation**: `decidim-debates/lib/decidim/api/mutations/`
- **Tests**: `decidim-debates/spec/types/create_debate_type_spec.rb`
- **Full Docs**: `decidim-debates/CREATE_DEBATE_MUTATION.md`

## Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| "Title can't be blank" | Missing title | Provide a title |
| "Not authorized" | No permission | Check user has create permission |
| "Component not found" | Invalid ID | Verify component ID |
| "Creation not enabled" | Disabled feature | Enable in component settings |

## Testing

```bash
cd decidim-debates
bundle exec rspec spec/types/create_debate_type_spec.rb
```

## Need More Help?

See full documentation:
- `decidim-debates/CREATE_DEBATE_MUTATION.md` - Complete usage guide
- `IMPLEMENTATION_SUMMARY.md` - Implementation details
- `decidim-debates/lib/decidim/api/mutations/README.md` - API reference
