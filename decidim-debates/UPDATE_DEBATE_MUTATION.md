# UpdateDebate GraphQL Mutation

## Overview

The `UpdateDebate` mutation allows authorized users to update a debate through the GraphQL API. This mutation follows the same pattern as the `AnswerProposal` mutation in the proposals module.

## Authorization

- The user must be the author of the debate
- Administrators and API users with proper permissions can also update debates

## Input Schema

The mutation uses the `DebateAttributes` input type with the following fields:

```graphql
input DebateAttributes {
  title: String
  description: String
  taxonomyIds: [ID!]
}
```

### Fields:
- **title** (String, optional): The updated title for the debate
- **description** (String, optional): The updated description for the debate
- **taxonomyIds** ([ID!], optional): An array of taxonomy IDs to categorize the debate

## Return Type

The mutation returns a `DebateType` object with the updated debate information.

## Usage Examples

### Example 1: Basic Update (Title and Description)

```graphql
mutation {
  component(id: "COMPONENT_ID") {
    ... on Debates {
      debate(id: "DEBATE_ID") {
        update(input: {
          attributes: {
            title: "Updated Debate Title"
            description: "This is the updated description for the debate."
          }
        }) {
          id
          title {
            translation(locale: "en")
          }
          description {
            translation(locale: "en")
          }
          updatedAt
        }
      }
    }
  }
}
```

### Example 2: Update with Taxonomies

```graphql
mutation {
  component(id: "COMPONENT_ID") {
    ... on Debates {
      debate(id: "DEBATE_ID") {
        update(input: {
          attributes: {
            title: "Budget Discussion 2024"
            description: "Let's discuss the municipal budget for the upcoming year."
            taxonomyIds: ["TAXONOMY_ID_1", "TAXONOMY_ID_2"]
          }
        }) {
          id
          title {
            translation(locale: "en")
          }
          description {
            translation(locale: "en")
          }
          taxonomies {
            id
            name {
              translation(locale: "en")
            }
          }
          updatedAt
        }
      }
    }
  }
}
```

### Example 3: Update Only Title

```graphql
mutation {
  component(id: "COMPONENT_ID") {
    ... on Debates {
      debate(id: "DEBATE_ID") {
        update(input: {
          attributes: {
            title: "New Debate Title"
          }
        }) {
          id
          title {
            translation(locale: "en")
          }
        }
      }
    }
  }
}
```

## Full Query Example with Variables

### Query:
```graphql
mutation UpdateDebate($componentId: ID!, $debateId: ID!, $title: String!, $description: String!, $taxonomyIds: [ID!]) {
  component(id: $componentId) {
    ... on Debates {
      debate(id: $debateId) {
        update(input: {
          attributes: {
            title: $title
            description: $description
            taxonomyIds: $taxonomyIds
          }
        }) {
          id
          title {
            translation(locale: "en")
          }
          description {
            translation(locale: "en")
          }
          taxonomies {
            id
            name {
              translation(locale: "en")
            }
          }
          author {
            name
          }
          createdAt
          updatedAt
        }
      }
    }
  }
}
```

### Variables:
```json
{
  "componentId": "123",
  "debateId": "456",
  "title": "Community Budget Planning",
  "description": "Join us in discussing how we should allocate the community budget for 2024.",
  "taxonomyIds": ["789", "101"]
}
```

## cURL Example

Here's how to call the mutation using cURL:

```bash
curl -X POST https://your-decidim-instance.com/api \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -d '{
    "query": "mutation { component(id: \"123\") { ... on Debates { debate(id: \"456\") { update(input: { attributes: { title: \"Updated Title\", description: \"Updated Description\" } }) { id title { translation(locale: \"en\") } description { translation(locale: \"en\") } } } } } }"
  }'
```

## Error Handling

The mutation will return errors in the following cases:

1. **Unauthorized**: User is not the debate author or doesn't have permission to edit
```json
{
  "data": {
    "component": {
      "debate": {
        "update": null
      }
    }
  },
  "errors": [
    {
      "message": "Not authorized"
    }
  ]
}
```

2. **Invalid Input**: Form validation fails (e.g., empty title)
```json
{
  "data": {
    "component": {
      "debate": {
        "update": null
      }
    }
  },
  "errors": [
    {
      "message": "Title can't be blank, Description can't be blank"
    }
  ]
}
```

## Integration with Decidim Components

The mutation integrates with the existing `UpdateDebate` command located in:
- `decidim-debates/app/commands/decidim/debates/update_debate.rb`

It uses the `DebateForm` for validation and processing, ensuring consistency with the web interface.

## Testing

Specs are located in:
- `decidim-debates/spec/types/debate_mutation_type_spec.rb`

Run the specs with:
```bash
bundle exec rspec decidim-debates/spec/types/debate_mutation_type_spec.rb
```

## Related Files

- Mutation Definition: `decidim-debates/lib/decidim/api/mutations/update_debate_type.rb`
- Input Schema: `decidim-debates/lib/decidim/api/mutations/update_debate_attributes.rb`
- Mutation Type: `decidim-debates/lib/decidim/api/mutations/debate_mutation_type.rb`
- Component Mutation: `decidim-debates/lib/decidim/api/mutations/debates_mutation_type.rb`
- Command: `decidim-debates/app/commands/decidim/debates/update_debate.rb`
- Form: `decidim-debates/app/forms/decidim/debates/debate_form.rb`
