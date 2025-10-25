# CloseDebate Mutation Documentation

## Overview

The `CloseDebate` mutation allows authorized users to close a debate by providing conclusions. This mutation is inspired by the existing `ProposalAnswer` mutation pattern in the decidim-proposals module.

## GraphQL Schema

### Mutation Type

```graphql
type DebateMutation {
  close(input: CloseDebateInput!): Debate
}
```

### Input Type

```graphql
input CloseDebateInput {
  attributes: CloseDebateAttributes!
}

input CloseDebateAttributes {
  conclusions: JSON!
}
```

### Return Type

Returns a `Debate` object with the following relevant fields:
- `id`: The debate ID
- `conclusions`: The conclusions for closing the debate (translatable)
- `closedAt`: The timestamp when the debate was closed

## Authorization

The mutation requires the user to have permission to close the debate. This is typically granted to:
- The debate author
- Administrators
- API users with appropriate permissions

The authorization is checked using the `allowed_to?(:close, :debate, object, context)` permission.

## Usage Examples

### Example 1: Close a Debate with Conclusions (Basic)

```graphql
mutation CloseDebate {
  debates(
    manifest: "debates"
    id: 1
  ) {
    debate(id: "123") {
      close(input: {
        attributes: {
          conclusions: {
            en: "After thorough discussion, we have reached a consensus on the key points. The community has agreed to move forward with the proposed action items."
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

### Example 2: Close a Debate with Multilingual Conclusions

```graphql
mutation CloseDebateMultilingual {
  debates(
    manifest: "debates"
    id: 1
  ) {
    debate(id: "456") {
      close(input: {
        attributes: {
          conclusions: {
            en: "The debate has concluded with the following outcomes and agreed-upon next steps for implementation.",
            es: "El debate ha concluido con los siguientes resultados y los próximos pasos acordados para la implementación.",
            fr: "Le débat s'est conclu avec les résultats suivants et les prochaines étapes convenues pour la mise en œuvre."
          }
        }
      }) {
        id
        title {
          translations {
            locale
            text
          }
        }
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

### Example 3: Using with JavaScript/TypeScript (Apollo Client)

```typescript
import { gql, useMutation } from '@apollo/client';

const CLOSE_DEBATE_MUTATION = gql`
  mutation CloseDebate($debateId: ID!, $componentId: ID!, $conclusions: JSON!) {
    debates(manifest: "debates", id: $componentId) {
      debate(id: $debateId) {
        close(input: {
          attributes: {
            conclusions: $conclusions
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
`;

function CloseDebateButton({ debateId, componentId }) {
  const [closeDebate, { data, loading, error }] = useMutation(CLOSE_DEBATE_MUTATION);

  const handleClose = async () => {
    try {
      await closeDebate({
        variables: {
          debateId: debateId,
          componentId: componentId,
          conclusions: {
            en: "The debate has been closed with the following conclusions..."
          }
        }
      });
      console.log('Debate closed successfully:', data);
    } catch (err) {
      console.error('Error closing debate:', err);
    }
  };

  return (
    <button onClick={handleClose} disabled={loading}>
      {loading ? 'Closing...' : 'Close Debate'}
    </button>
  );
}
```

### Example 4: Using with Ruby (HTTP Client)

```ruby
require 'net/http'
require 'json'
require 'uri'

def close_debate(api_url, token, component_id, debate_id, conclusions)
  uri = URI.parse("#{api_url}/api")
  
  query = <<~GRAPHQL
    mutation CloseDebate($debateId: ID!, $componentId: ID!, $conclusions: JSON!) {
      debates(manifest: "debates", id: $componentId) {
        debate(id: $debateId) {
          close(input: {
            attributes: {
              conclusions: $conclusions
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
  GRAPHQL

  variables = {
    debateId: debate_id,
    componentId: component_id,
    conclusions: conclusions
  }

  request = Net::HTTP::Post.new(uri)
  request.content_type = "application/json"
  request["Authorization"] = "Bearer #{token}"
  request.body = JSON.dump({
    query: query,
    variables: variables
  })

  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
    http.request(request)
  end

  JSON.parse(response.body)
end

# Usage
result = close_debate(
  "https://your-decidim-instance.org",
  "your-api-token",
  "1",
  "123",
  {
    en: "After comprehensive discussion, we have reached the following conclusions..."
  }
)

puts "Debate closed at: #{result.dig('data', 'debates', 'debate', 'close', 'closedAt')}"
```

### Example 5: Using with Python (requests library)

```python
import requests
import json

def close_debate(api_url, token, component_id, debate_id, conclusions):
    """Close a debate using the GraphQL API"""
    
    query = """
        mutation CloseDebate($debateId: ID!, $componentId: ID!, $conclusions: JSON!) {
            debates(manifest: "debates", id: $componentId) {
                debate(id: $debateId) {
                    close(input: {
                        attributes: {
                            conclusions: $conclusions
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
    """
    
    variables = {
        "debateId": debate_id,
        "componentId": component_id,
        "conclusions": conclusions
    }
    
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {token}"
    }
    
    response = requests.post(
        f"{api_url}/api",
        json={"query": query, "variables": variables},
        headers=headers
    )
    
    return response.json()

# Usage
result = close_debate(
    api_url="https://your-decidim-instance.org",
    token="your-api-token",
    component_id="1",
    debate_id="123",
    conclusions={
        "en": "After comprehensive discussion, we have reached the following conclusions..."
    }
)

if "errors" in result:
    print("Errors:", result["errors"])
else:
    closed_at = result["data"]["debates"]["debate"]["close"]["closedAt"]
    print(f"Debate closed successfully at: {closed_at}")
```

### Example 6: Using with cURL

```bash
curl -X POST https://your-decidim-instance.org/api \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -d '{
    "query": "mutation CloseDebate($debateId: ID!, $componentId: ID!, $conclusions: JSON!) { debates(manifest: \"debates\", id: $componentId) { debate(id: $debateId) { close(input: { attributes: { conclusions: $conclusions } }) { id title { translation(locale: \"en\") } conclusions { translation(locale: \"en\") } closedAt } } } }",
    "variables": {
      "debateId": "123",
      "componentId": "1",
      "conclusions": {
        "en": "After comprehensive discussion, we have reached the following conclusions and agreed on the next steps."
      }
    }
  }'
```

## Validation Rules

The mutation validates the following:

1. **Conclusions Presence**: Conclusions must be provided and cannot be empty.
2. **Conclusions Length**: Conclusions must be at least 10 characters and at most 10,000 characters.
3. **User Authorization**: The user must have permission to close the debate (via `closeable_by?` method).
4. **Debate Existence**: The debate must exist and not be hidden.

## Error Handling

The mutation returns a `GraphQL::ExecutionError` in the following cases:

1. **Form Validation Errors**: If the conclusions don't meet the validation requirements.
2. **Authorization Errors**: If the user doesn't have permission to close the debate.
3. **Command Execution Errors**: If the CloseDebate command fails for any reason.

### Example Error Response

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

## Integration with Decidim

This mutation integrates with the existing Decidim Debates module by:

1. Using the `Decidim::Debates::CloseDebateForm` for form validation
2. Calling the `Decidim::Debates::CloseDebate` command to perform the action
3. Publishing the `decidim.events.debates.debate_closed` event
4. Respecting the existing permission system via `closeable_by?`

## Testing

The mutation includes comprehensive RSpec tests covering:

- Admin user closing debates
- Debate authors closing their own debates
- API users with appropriate permissions
- Unauthorized users being rejected
- Validation errors for invalid conclusions
- Successful closure with proper conclusions

To run the tests:

```bash
bundle exec rspec decidim-debates/spec/types/debate_mutation_type_spec.rb
```

## Related Files

- **Mutation**: `decidim-debates/lib/decidim/api/mutations/close_debate_type.rb`
- **Input**: `decidim-debates/lib/decidim/api/mutations/close_debate_attributes.rb`
- **Wrapper**: `decidim-debates/lib/decidim/api/mutations/debate_mutation_type.rb`
- **Entry Point**: `decidim-debates/lib/decidim/api/mutations/debates_mutation_type.rb`
- **Command**: `decidim-debates/app/commands/decidim/debates/close_debate.rb`
- **Form**: `decidim-debates/app/forms/decidim/debates/close_debate_form.rb`
- **Tests**: `decidim-debates/spec/types/debate_mutation_type_spec.rb`

## References

This implementation is based on:
- [Decidim PR #14996](https://github.com/decidim/decidim/pull/14996)
- [Decidim PR #14974](https://github.com/decidim/decidim/pull/14974)
- [Decidim PR #14911](https://github.com/decidim/decidim/pull/14911)
- [Decidim PR #14885](https://github.com/decidim/decidim/pull/14885)
- [Decidim PR #14881](https://github.com/decidim/decidim/pull/14881)
- Existing `ProposalAnswer` mutation in `decidim-proposals`
