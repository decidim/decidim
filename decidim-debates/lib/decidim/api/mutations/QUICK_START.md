# Quick Start Guide: CloseDebate Mutation

This guide provides a quick reference for using the CloseDebate mutation in your Decidim application.

## Prerequisites

- You need to have a Decidim instance with the debates component enabled
- You need authentication (API token or user session)
- You need permission to close the debate (be the author, admin, or have appropriate API permissions)

## Basic Usage

### 1. Identify Your Resources

You need:
- **Component ID**: The ID of the debates component (e.g., `1`)
- **Debate ID**: The ID of the debate you want to close (e.g., `"123"`)

### 2. Make the GraphQL Request

```graphql
mutation CloseDebate {
  debates(manifest: "debates", id: 1) {
    debate(id: "123") {
      close(input: {
        attributes: {
          conclusions: {
            en: "After extensive discussion, we have agreed on the following key points and next steps for implementation."
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

### 3. Response Format

#### Success Response

```json
{
  "data": {
    "debates": {
      "debate": {
        "close": {
          "id": "123",
          "title": {
            "translation": "Community Budget Priorities"
          },
          "conclusions": {
            "translation": "After extensive discussion, we have agreed on the following key points and next steps for implementation."
          },
          "closedAt": "2024-10-25T10:30:00Z"
        }
      }
    }
  }
}
```

#### Error Response

```json
{
  "data": {
    "debates": {
      "debate": {
        "close": null
      }
    }
  },
  "errors": [
    {
      "message": "Conclusions is too short (minimum is 10 characters)",
      "locations": [{"line": 3, "column": 7}],
      "path": ["debates", "debate", "close"]
    }
  ]
}
```

## Common Use Cases

### Close with Single Language

```graphql
mutation {
  debates(manifest: "debates", id: 1) {
    debate(id: "456") {
      close(input: {
        attributes: {
          conclusions: {
            en: "This debate has concluded successfully with consensus on all major points."
          }
        }
      }) {
        id
        closedAt
      }
    }
  }
}
```

### Close with Multiple Languages

```graphql
mutation {
  debates(manifest: "debates", id: 1) {
    debate(id: "789") {
      close(input: {
        attributes: {
          conclusions: {
            en: "The debate concluded with agreement on next steps.",
            es: "El debate concluyó con acuerdo sobre los próximos pasos.",
            fr: "Le débat s'est terminé avec un accord sur les prochaines étapes."
          }
        }
      }) {
        id
        conclusions {
          translations {
            locale
            text
          }
        }
        closedAt
      }
    }
  }
}
```

## Validation Rules

✅ **Valid Conclusions**
- Minimum length: 10 characters
- Maximum length: 10,000 characters
- Cannot be empty

❌ **Invalid Conclusions**
- Too short: `"Short"` (less than 10 characters)
- Empty: `""` or `{}`
- Missing: No conclusions provided

## HTTP Request Example

### Using cURL

```bash
# Set your variables
API_URL="https://your-decidim-instance.org"
TOKEN="your-api-token"
COMPONENT_ID="1"
DEBATE_ID="123"

# Make the request
curl -X POST "${API_URL}/api" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d '{
    "query": "mutation($componentId: ID!, $debateId: ID!, $conclusions: JSON!) { debates(manifest: \"debates\", id: $componentId) { debate(id: $debateId) { close(input: { attributes: { conclusions: $conclusions } }) { id closedAt } } } }",
    "variables": {
      "componentId": "'"${COMPONENT_ID}"'",
      "debateId": "'"${DEBATE_ID}"'",
      "conclusions": {
        "en": "Debate conclusions here..."
      }
    }
  }'
```

## Troubleshooting

### "User not authorized" Error

**Problem**: You don't have permission to close the debate.

**Solution**: Ensure you are:
- The debate author, OR
- An administrator, OR
- An API user with appropriate permissions

### "Conclusions is too short" Error

**Problem**: Your conclusions text is less than 10 characters.

**Solution**: Provide at least 10 characters of meaningful conclusions.

### "Debate not found" Error

**Problem**: The debate ID doesn't exist or is hidden.

**Solution**: Verify the debate ID and ensure the debate is not hidden.

## Next Steps

- See `CLOSE_DEBATE_MUTATION.md` for comprehensive documentation
- See `README.md` for architecture details
- Check the test files for more examples

## Support

For issues or questions:
- Check the Decidim documentation: https://docs.decidim.org/
- Review the mutation specs: `decidim-debates/spec/types/debate_mutation_type_spec.rb`
- Check existing debates controller: `decidim-debates/app/controllers/decidim/debates/debates_controller.rb`
