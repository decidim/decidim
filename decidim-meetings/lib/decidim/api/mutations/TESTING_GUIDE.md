# UpdateMeeting Mutation - Quick Test Guide

## Overview
This guide helps you manually test the UpdateMeeting GraphQL mutation.

## Prerequisites
1. A running Decidim instance with the API enabled
2. API credentials (Bearer token or OAuth token)
3. An existing meeting that you have permission to update

## How to Test

### 1. Using GraphiQL (Web Interface)

Navigate to: `https://your-decidim-instance.org/api/graphiql`

Login with your credentials, then run:

```graphql
# First, find a meeting ID
query FindMeetings {
  participatoryProcess(id: YOUR_PROCESS_ID) {
    components {
      ... on Meetings {
        meetings {
          edges {
            node {
              id
              title { translation(locale: "en") }
            }
          }
        }
      }
    }
  }
}

# Then update the meeting
mutation UpdateMeeting {
  meetings {
    meeting(id: "MEETING_ID_HERE") {
      update(input: {
        attributes: {
          title: { en: "My Updated Meeting Title" }
          description: { en: "This is the updated description" }
        }
      }) {
        id
        title { translation(locale: "en") }
        description { translation(locale: "en") }
        updatedAt
      }
    }
  }
}
```

### 2. Using cURL

```bash
# Store your credentials
TOKEN="your_api_token_here"
API_URL="https://your-decidim-instance.org/api"
MEETING_ID="123"

# Update the meeting
curl -X POST "$API_URL" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "query": "mutation { meetings { meeting(id: \"'$MEETING_ID'\") { update(input: { attributes: { title: { en: \"Updated Title\" } } }) { id title { translation(locale: \"en\") } } } } }"
  }'
```

### 3. Expected Response

Successful response:
```json
{
  "data": {
    "meetings": {
      "meeting": {
        "update": {
          "id": "123",
          "title": {
            "translation": "Updated Title"
          },
          "updatedAt": "2025-11-01T10:30:00Z"
        }
      }
    }
  }
}
```

Error response:
```json
{
  "data": {
    "meetings": {
      "meeting": {
        "update": null
      }
    }
  },
  "errors": [
    {
      "message": "Title can't be blank",
      "locations": [{"line": 3, "column": 9}],
      "path": ["meetings", "meeting", "update"]
    }
  ]
}
```

## Common Test Scenarios

### Scenario 1: Update Basic Info
```graphql
mutation {
  meetings {
    meeting(id: "123") {
      update(input: {
        attributes: {
          title: { en: "Community Workshop" }
          description: { en: "Join us for an interactive workshop" }
        }
      }) {
        id
        title { translation(locale: "en") }
      }
    }
  }
}
```

### Scenario 2: Update Meeting Times
```graphql
mutation {
  meetings {
    meeting(id: "123") {
      update(input: {
        attributes: {
          startTime: "2025-12-01T14:00:00Z"
          endTime: "2025-12-01T16:00:00Z"
        }
      }) {
        id
        startTime
        endTime
      }
    }
  }
}
```

### Scenario 3: Change to Online Meeting
```graphql
mutation {
  meetings {
    meeting(id: "123") {
      update(input: {
        attributes: {
          typeOfMeeting: "online"
          onlineMeetingUrl: "https://meet.example.org/my-meeting"
        }
      }) {
        id
        typeOfMeeting
        onlineMeetingUrl
      }
    }
  }
}
```

### Scenario 4: Update Registration Settings
```graphql
mutation {
  meetings {
    meeting(id: "123") {
      update(input: {
        attributes: {
          registrationType: "on_this_platform"
          availableSlots: 100
          registrationTerms: { en: "Please arrive 10 minutes early" }
        }
      }) {
        id
        registrationType
        availableSlots
        registrationTerms { translation(locale: "en") }
      }
    }
  }
}
```

## Testing Authorization

### Test 1: As Meeting Author
- Create a meeting as User A
- Try to update as User A → Should succeed ✓

### Test 2: As Admin
- Create a meeting as User A
- Try to update as Admin → Should succeed ✓

### Test 3: As Different User
- Create a meeting as User A
- Try to update as User B (non-admin) → Should fail with authorization error ✗

### Test 4: With API User
- Create a meeting
- Try to update with API credentials (api:read, api:write scopes) → Should succeed ✓

## Validation Testing

### Test Invalid Data
```graphql
# Empty title - should fail
mutation {
  meetings {
    meeting(id: "123") {
      update(input: {
        attributes: {
          title: { en: "" }
        }
      }) {
        id
      }
    }
  }
}
```

### Test Invalid Date Range
```graphql
# End time before start time - should fail
mutation {
  meetings {
    meeting(id: "123") {
      update(input: {
        attributes: {
          startTime: "2025-12-01T16:00:00Z"
          endTime: "2025-12-01T14:00:00Z"
        }
      }) {
        id
      }
    }
  }
}
```

## Troubleshooting

### Issue: "Meeting not found"
- Verify the meeting ID exists
- Ensure the meeting is published and not hidden
- Check you're querying the correct component

### Issue: "Authorization error" 
- Verify your user has permission to update the meeting
- Ensure you're the author or an admin
- Check your API token has correct scopes (api:read, api:write)

### Issue: "Validation failed"
- Check required fields are present (title, start_time, end_time)
- Verify dates are in correct order (start before end)
- For online/hybrid meetings, ensure online_meeting_url is provided
- For in-person/hybrid meetings, ensure address is provided

## Next Steps

After successful testing:
1. Review the mutation logs
2. Verify the meeting is updated in the database
3. Check that notifications are sent to followers (if dates/address changed)
4. Confirm the meeting displays correctly in the UI

## Support

For detailed API documentation, see:
- `UPDATE_MEETING_USAGE.md` - Complete usage examples
- GraphQL Schema documentation at `/api/graphiql`
- Decidim API docs: https://docs.decidim.org
