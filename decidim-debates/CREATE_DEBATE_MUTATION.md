# CreateDebate Mutation Documentation

## Overview

This document describes how to use the `CreateDebate` mutation in the Decidim GraphQL API to create debates programmatically.

## Files Created

### Mutation Classes
- `decidim-debates/lib/decidim/api/mutations/create_debate_attributes.rb` - Input type for debate attributes
- `decidim-debates/lib/decidim/api/mutations/create_debate_type.rb` - Main mutation implementation
- `decidim-debates/lib/decidim/api/mutations/debate_mutation_type.rb` - Debate mutation wrapper
- `decidim-debates/lib/decidim/api/mutations/debates_mutation_type.rb` - Component-level mutation type

### Specs
- `decidim-debates/spec/types/create_debate_type_spec.rb` - Main mutation spec
- `decidim-debates/spec/shared/debate_mutation_examples.rb` - Shared examples for mutation tests

## GraphQL Schema

### Input Type: DebateAttributes

```graphql
input DebateAttributes {
  title: String!
  description: String!
  taxonomyIds: [ID!]
}
```

### Mutation: CreateDebate

```graphql
mutation CreateDebate($input: CreateDebateInput!) {
  createDebate(input: $input) {
    id
    title {
      translation(locale: String!)
    }
    description {
      translation(locale: String!)
    }
    taxonomies {
      id
      name {
        translation(locale: String!)
      }
    }
    author {
      id
      name
    }
    createdAt
    updatedAt
  }
}
```

## Usage Examples

### Example 1: Create a Basic Debate

**GraphQL Query:**
```graphql
mutation {
  createDebate(input: {
    componentId: "123",
    attributes: {
      title: "Should every organization use Decidim?",
      description: "Add your comments on whether Decidim is useful for every organization."
    }
  }) {
    id
    title {
      translation(locale: "en")
    }
    description {
      translation(locale: "en")
    }
    author {
      id
      name
    }
  }
}
```

**Response:**
```json
{
  "data": {
    "createDebate": {
      "id": "456",
      "title": {
        "translation": "Should every organization use Decidim?"
      },
      "description": {
        "translation": "Add your comments on whether Decidim is useful for every organization."
      },
      "author": {
        "id": "789",
        "name": "John Doe"
      }
    }
  }
}
```

### Example 2: Create a Debate with Taxonomies

**GraphQL Query:**
```graphql
mutation {
  createDebate(input: {
    componentId: "123",
    attributes: {
      title: "Community Engagement Strategy",
      description: "Let's discuss how we can improve community engagement in our city.",
      taxonomyIds: ["101", "102"]
    }
  }) {
    id
    title {
      translation(locale: "en")
    }
    taxonomies {
      id
      name {
        translation(locale: "en")
      }
    }
  }
}
```

**Response:**
```json
{
  "data": {
    "createDebate": {
      "id": "457",
      "title": {
        "translation": "Community Engagement Strategy"
      },
      "taxonomies": [
        {
          "id": "101",
          "name": {
            "translation": "Social Issues"
          }
        },
        {
          "id": "102",
          "name": {
            "translation": "Community Development"
          }
        }
      ]
    }
  }
}
```

### Example 3: Using with Variables

**GraphQL Query:**
```graphql
mutation CreateDebateMutation($componentId: ID!, $title: String!, $description: String!, $taxonomyIds: [ID!]) {
  createDebate(input: {
    componentId: $componentId,
    attributes: {
      title: $title,
      description: $description,
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
  }
}
```

**Variables:**
```json
{
  "componentId": "123",
  "title": "Climate Action Plan",
  "description": "How can we address climate change in our community?",
  "taxonomyIds": ["105"]
}
```

## cURL Examples

### Example 1: Using cURL with Access Token

```bash
curl -X POST https://your-decidim-instance.org/api \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d '{
    "query": "mutation { createDebate(input: { componentId: \"123\", attributes: { title: \"Should every organization use Decidim?\", description: \"Add your comments on whether Decidim is useful for every organization.\" } }) { id title { translation(locale: \"en\") } } }"
  }'
```

### Example 2: Using cURL with Variables

```bash
curl -X POST https://your-decidim-instance.org/api \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d '{
    "query": "mutation CreateDebateMutation($componentId: ID!, $title: String!, $description: String!) { createDebate(input: { componentId: $componentId, attributes: { title: $title, description: $description } }) { id title { translation(locale: \"en\") } } }",
    "variables": {
      "componentId": "123",
      "title": "Climate Action Plan",
      "description": "How can we address climate change in our community?"
    }
  }'
```

## JavaScript/TypeScript Example

```typescript
const DECIDIM_API_URL = 'https://your-decidim-instance.org/api';
const ACCESS_TOKEN = 'YOUR_ACCESS_TOKEN';

const CREATE_DEBATE_MUTATION = `
  mutation CreateDebate($componentId: ID!, $title: String!, $description: String!, $taxonomyIds: [ID!]) {
    createDebate(input: {
      componentId: $componentId,
      attributes: {
        title: $title,
        description: $description,
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
    }
  }
`;

async function createDebate(componentId: string, title: string, description: string, taxonomyIds?: string[]) {
  const response = await fetch(DECIDIM_API_URL, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${ACCESS_TOKEN}`
    },
    body: JSON.stringify({
      query: CREATE_DEBATE_MUTATION,
      variables: {
        componentId,
        title,
        description,
        taxonomyIds: taxonomyIds || []
      }
    })
  });

  const result = await response.json();
  
  if (result.errors) {
    throw new Error(result.errors[0].message);
  }
  
  return result.data.createDebate;
}

// Usage
createDebate(
  '123',
  'Should every organization use Decidim?',
  'Add your comments on whether Decidim is useful for every organization.',
  ['101', '102']
).then(debate => {
  console.log('Created debate:', debate);
}).catch(error => {
  console.error('Error creating debate:', error);
});
```

## Ruby Example

```ruby
require 'net/http'
require 'json'
require 'uri'

class DecidimAPI
  def initialize(api_url, access_token)
    @api_url = api_url
    @access_token = access_token
  end

  def create_debate(component_id, title, description, taxonomy_ids = [])
    query = <<~GRAPHQL
      mutation CreateDebate($componentId: ID!, $title: String!, $description: String!, $taxonomyIds: [ID!]) {
        createDebate(input: {
          componentId: $componentId,
          attributes: {
            title: $title,
            description: $description,
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
        }
      }
    GRAPHQL

    variables = {
      componentId: component_id,
      title: title,
      description: description,
      taxonomyIds: taxonomy_ids
    }

    uri = URI.parse(@api_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')

    request = Net::HTTP::Post.new(uri.path)
    request['Content-Type'] = 'application/json'
    request['Authorization'] = "Bearer #{@access_token}"
    request.body = { query: query, variables: variables }.to_json

    response = http.request(request)
    result = JSON.parse(response.body)

    if result['errors']
      raise result['errors'][0]['message']
    end

    result['data']['createDebate']
  end
end

# Usage
api = DecidimAPI.new('https://your-decidim-instance.org/api', 'YOUR_ACCESS_TOKEN')
debate = api.create_debate(
  '123',
  'Should every organization use Decidim?',
  'Add your comments on whether Decidim is useful for every organization.',
  ['101', '102']
)

puts "Created debate: #{debate['id']}"
```

## Authentication

The `createDebate` mutation requires authentication. You need to:

1. **Obtain an Access Token**: Register an OAuth application in Decidim and obtain an access token with the required scopes (`api:read` and `api:write`).

2. **Include the Token**: Add the token in the Authorization header:
   ```
   Authorization: Bearer YOUR_ACCESS_TOKEN
   ```

## Authorization

The mutation checks the following permissions:
- The user must be authenticated
- The user must have permission to create debates in the specified component
- The component must have debate creation enabled

## Error Handling

The mutation can return the following errors:

1. **Validation Errors**: When the input data is invalid
   ```json
   {
     "errors": [
       {
         "message": "Title can't be blank, Description can't be blank"
       }
     ]
   }
   ```

2. **Permission Errors**: When the user doesn't have permission
   ```json
   {
     "errors": [
       {
         "message": "You are not authorized to perform this action"
       }
     ]
   }
   ```

3. **Component Not Found**: When the component ID is invalid
   ```json
   {
     "errors": [
       {
         "message": "Couldn't find Component with 'id'=123"
       }
     ]
   }
   ```

## Best Practices

1. **Validate Input**: Always validate the title and description before sending the mutation
2. **Handle Errors**: Implement proper error handling in your application
3. **Use Variables**: Use GraphQL variables instead of string interpolation for security
4. **Check Permissions**: Verify that debate creation is enabled before attempting to create a debate
5. **Locale Support**: Decidim supports multiple locales, but debates created via API use the user's current locale

## Testing

Run the specs with:
```bash
cd decidim-debates
bundle exec rspec spec/types/create_debate_type_spec.rb
```

## Related Documentation

- [Decidim GraphQL API Documentation](https://docs.decidim.org/develop/en/services/graphql.html)
- [Decidim Debates Module](https://docs.decidim.org/develop/en/modules/debates.html)
- [GraphQL Official Documentation](https://graphql.org/learn/)
