# WithdrawMeeting GraphQL Mutation - Usage Example

## Overview

The `WithdrawMeeting` mutation allows authenticated users to withdraw meetings they have authored. This mutation uses the existing `Decidim::Meetings::WithdrawMeeting` command and follows the same authorization rules.

## Prerequisites

- The user must be authenticated with proper API credentials
- The user must be the author of the meeting
- The meeting must not be already withdrawn
- The meeting must be published and not hidden

## GraphQL Mutation Structure

### Basic Mutation Query

```graphql
mutation WithdrawMeeting($componentId: ID!, $meetingId: ID!) {
  meetings(id: $componentId) {
    meeting(id: $meetingId) {
      withdraw(input: { attributes: {} }) {
        id
        title {
          translation(locale: "en")
        }
        withdrawn
        withdrawnAt
        author {
          id
          name
        }
      }
    }
  }
}
```

### Variables

```json
{
  "componentId": "123",
  "meetingId": "456"
}
```

## Complete HTTP Request Example

### Using cURL

```bash
curl -X POST https://your-decidim-instance.com/api \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -d '{
    "query": "mutation WithdrawMeeting($componentId: ID!, $meetingId: ID!) { meetings(id: $componentId) { meeting(id: $meetingId) { withdraw(input: { attributes: {} }) { id title { translation(locale: \"en\") } withdrawn withdrawnAt author { id name } } } } }",
    "variables": {
      "componentId": "123",
      "meetingId": "456"
    }
  }'
```

### Using JavaScript (fetch)

```javascript
const withdrawMeeting = async (componentId, meetingId, apiToken) => {
  const query = `
    mutation WithdrawMeeting($componentId: ID!, $meetingId: ID!) {
      meetings(id: $componentId) {
        meeting(id: $meetingId) {
          withdraw(input: { attributes: {} }) {
            id
            title {
              translation(locale: "en")
            }
            withdrawn
            withdrawnAt
            author {
              id
              name
            }
          }
        }
      }
    }
  `;

  const response = await fetch('https://your-decidim-instance.com/api', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${apiToken}`
    },
    body: JSON.stringify({
      query,
      variables: {
        componentId,
        meetingId
      }
    })
  });

  const result = await response.json();
  return result.data;
};

// Usage
withdrawMeeting('123', '456', 'your-api-token')
  .then(data => {
    console.log('Meeting withdrawn:', data.meetings.meeting.withdraw);
  })
  .catch(error => {
    console.error('Error:', error);
  });
```

### Using Python (requests)

```python
import requests
import json

def withdraw_meeting(component_id, meeting_id, api_token):
    url = "https://your-decidim-instance.com/api"
    
    query = """
    mutation WithdrawMeeting($componentId: ID!, $meetingId: ID!) {
      meetings(id: $componentId) {
        meeting(id: $meetingId) {
          withdraw(input: { attributes: {} }) {
            id
            title {
              translation(locale: "en")
            }
            withdrawn
            withdrawnAt
            author {
              id
              name
            }
          }
        }
      }
    }
    """
    
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {api_token}"
    }
    
    payload = {
        "query": query,
        "variables": {
            "componentId": component_id,
            "meetingId": meeting_id
        }
    }
    
    response = requests.post(url, headers=headers, json=payload)
    return response.json()

# Usage
result = withdraw_meeting('123', '456', 'your-api-token')
print("Meeting withdrawn:", result['data']['meetings']['meeting']['withdraw'])
```

## Response Examples

### Successful Response

```json
{
  "data": {
    "meetings": {
      "meeting": {
        "withdraw": {
          "id": "456",
          "title": {
            "translation": "Community Planning Meeting"
          },
          "withdrawn": true,
          "withdrawnAt": "2025-10-25T07:15:41Z",
          "author": {
            "id": "789",
            "name": "John Doe"
          }
        }
      }
    }
  }
}
```

### Error Response (Unauthorized)

When the user is not the author:

```json
{
  "data": {
    "meetings": {
      "meeting": {
        "withdraw": null
      }
    }
  },
  "errors": [
    {
      "message": "Not authorized",
      "path": ["meetings", "meeting", "withdraw"]
    }
  ]
}
```

### Error Response (Invalid Meeting)

When the meeting cannot be withdrawn:

```json
{
  "data": {
    "meetings": {
      "meeting": {
        "withdraw": null
      }
    }
  },
  "errors": [
    {
      "message": "There was a problem withdrawing the meeting",
      "path": ["meetings", "meeting", "withdraw"]
    }
  ]
}
```

## Authorization

The mutation checks:
1. User has the `:withdraw` permission on the `:meeting` resource
2. User is the author of the meeting (via `meeting.authored_by?(current_user)`)

## Schema Definition

The mutation is structured as follows:

```graphql
type MeetingsMutationType {
  # Get a meeting to perform mutations on
  meeting(id: ID!): MeetingMutationType
}

type MeetingMutationType {
  # Withdraw the meeting
  withdraw(input: WithdrawMeetingInput!): Meeting
}

input WithdrawMeetingInput {
  attributes: WithdrawMeetingAttributes
}

input WithdrawMeetingAttributes {
  # No additional attributes required
}
```

## Notes

- The `attributes` field in the input is optional and empty, as the `WithdrawMeeting` command only requires the meeting and current user
- The mutation uses the existing `Decidim::Meetings::WithdrawMeeting` command from the decidim-meetings module
- The withdrawn meeting will have `withdrawn` set to `true` and `withdrawnAt` set to the current timestamp
- Once withdrawn, the meeting cannot be un-withdrawn through the API (this would require additional implementation)

## Testing the Mutation

You can test the mutation using GraphiQL interface available at:
```
https://your-decidim-instance.com/api/graphiql
```

Or use any GraphQL client like:
- Postman
- Insomnia
- Apollo Client
- GraphQL Playground

## Related Files

- Mutation: `decidim-meetings/lib/decidim/api/mutations/withdraw_meeting_type.rb`
- Command: `decidim-meetings/app/commands/decidim/meetings/withdraw_meeting.rb`
- Spec: `decidim-meetings/spec/types/meeting_mutation_type_spec.rb`
