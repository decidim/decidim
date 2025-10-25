# UpdateMeeting Mutation - Usage Examples

## Overview

The `UpdateMeeting` mutation allows authorized users to update existing meetings in a Decidim instance through the GraphQL API.

## Authorization

To use this mutation, you must be:
- The author of the meeting, OR
- An admin of the participatory space, OR
- An API user with the appropriate permissions

Required scopes: `api:read`, `api:write`

## GraphQL Schema

### Input Type: UpdateMeetingAttributes

```graphql
input UpdateMeetingAttributes {
  title: JSON
  description: JSON
  location: JSON
  locationHints: JSON
  startTime: DateTime
  endTime: DateTime
  address: String
  latitude: Float
  longitude: Float
  registrationType: String
  registrationUrl: String
  availableSlots: Int
  registrationTerms: JSON
  registrationsEnabled: Boolean
  typeOfMeeting: String
  onlineMeetingUrl: String
  iframeEmbedType: String
  iframeAccessLevel: String
}
```

### Mutation Type

```graphql
type MeetingMutation {
  update(input: UpdateMeetingInput!): Meeting
}
```

## Usage Examples

### Example 1: Update Basic Meeting Information

```graphql
mutation UpdateMeetingBasic {
  meetings {
    meeting(id: "123") {
      update(input: {
        attributes: {
          title: { en: "Updated Meeting Title" }
          description: { en: "This meeting has been updated with new information" }
          startTime: "2025-11-01T14:00:00Z"
          endTime: "2025-11-01T16:00:00Z"
        }
      }) {
        id
        title {
          translation(locale: "en")
        }
        description {
          translation(locale: "en")
        }
        startTime
        endTime
        updatedAt
      }
    }
  }
}
```

### Example 2: Update Meeting Location (In-Person Meeting)

```graphql
mutation UpdateMeetingLocation {
  meetings {
    meeting(id: "123") {
      update(input: {
        attributes: {
          typeOfMeeting: "in_person"
          address: "123 Main Street, City Center, 12345"
          latitude: 40.7128
          longitude: -74.0060
          location: { 
            en: "Conference Room A, Main Building" 
          }
          locationHints: { 
            en: "Enter through the main entrance and take elevator to 3rd floor" 
          }
        }
      }) {
        id
        typeOfMeeting
        address
        location {
          translation(locale: "en")
        }
        locationHints {
          translation(locale: "en")
        }
        coordinates {
          latitude
          longitude
        }
      }
    }
  }
}
```

### Example 3: Update Online Meeting Details

```graphql
mutation UpdateOnlineMeeting {
  meetings {
    meeting(id: "123") {
      update(input: {
        attributes: {
          typeOfMeeting: "online"
          onlineMeetingUrl: "https://meet.example.org/my-meeting"
          iframeEmbedType: "embed_in_meeting_page"
          iframeAccessLevel: "signed_in"
        }
      }) {
        id
        typeOfMeeting
        onlineMeetingUrl
        iframeEmbedType
        iframeAccessLevel
      }
    }
  }
}
```

### Example 4: Update Registration Settings

```graphql
mutation UpdateMeetingRegistration {
  meetings {
    meeting(id: "123") {
      update(input: {
        attributes: {
          registrationType: "on_this_platform"
          availableSlots: 50
          registrationsEnabled: true
          registrationTerms: {
            en: "By registering, you agree to attend the meeting and respect the code of conduct."
          }
        }
      }) {
        id
        registrationType
        registrationsEnabled
        availableSlots
        remainingSlots
        registrationTerms {
          translation(locale: "en")
        }
      }
    }
  }
}
```

### Example 5: Update Hybrid Meeting

```graphql
mutation UpdateHybridMeeting {
  meetings {
    meeting(id: "123") {
      update(input: {
        attributes: {
          typeOfMeeting: "hybrid"
          address: "123 Main Street, City Center"
          latitude: 40.7128
          longitude: -74.0060
          location: { en: "Main Conference Room" }
          onlineMeetingUrl: "https://meet.example.org/hybrid-meeting"
          iframeEmbedType: "open_in_new_tab"
        }
      }) {
        id
        typeOfMeeting
        address
        location {
          translation(locale: "en")
        }
        onlineMeetingUrl
      }
    }
  }
}
```

### Example 6: Multilingual Update

```graphql
mutation UpdateMultilingualMeeting {
  meetings {
    meeting(id: "123") {
      update(input: {
        attributes: {
          title: {
            en: "Community Meeting"
            es: "Reunión Comunitaria"
            fr: "Réunion Communautaire"
          }
          description: {
            en: "Join us for a community discussion"
            es: "Únete a nosotros para una discusión comunitaria"
            fr: "Rejoignez-nous pour une discussion communautaire"
          }
          location: {
            en: "City Hall"
            es: "Ayuntamiento"
            fr: "Hôtel de Ville"
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
        description {
          translations {
            locale
            text
          }
        }
      }
    }
  }
}
```

## Using with cURL

### Example cURL Request

```bash
curl -X POST https://your-decidim-instance.org/api \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -d '{
    "query": "mutation UpdateMeeting($input: UpdateMeetingInput!) { meetings { meeting(id: \"123\") { update(input: $input) { id title { translation(locale: \"en\") } } } } }",
    "variables": {
      "input": {
        "attributes": {
          "title": { "en": "Updated Meeting Title" },
          "description": { "en": "Updated description" }
        }
      }
    }
  }'
```

## Using with JavaScript/TypeScript

```typescript
const UPDATE_MEETING = gql`
  mutation UpdateMeeting($meetingId: ID!, $input: UpdateMeetingInput!) {
    meetings {
      meeting(id: $meetingId) {
        update(input: $input) {
          id
          title {
            translation(locale: "en")
          }
          description {
            translation(locale: "en")
          }
          startTime
          endTime
        }
      }
    }
  }
`;

// Using Apollo Client
const { data } = await client.mutate({
  mutation: UPDATE_MEETING,
  variables: {
    meetingId: "123",
    input: {
      attributes: {
        title: { en: "Updated Meeting Title" },
        description: { en: "Updated meeting description" },
        startTime: "2025-11-01T14:00:00Z",
        endTime: "2025-11-01T16:00:00Z"
      }
    }
  }
});
```

## Using with Ruby

```ruby
require 'graphql/client'
require 'graphql/client/http'

# Configure the client
HTTP = GraphQL::Client::HTTP.new("https://your-decidim-instance.org/api") do
  def headers(context)
    {
      "Authorization" => "Bearer YOUR_API_TOKEN",
      "Content-Type" => "application/json"
    }
  end
end

Schema = GraphQL::Client.load_schema(HTTP)
Client = GraphQL::Client.new(schema: Schema, execute: HTTP)

# Define the mutation
UpdateMeetingMutation = Client.parse <<-GRAPHQL
  mutation($meetingId: ID!, $input: UpdateMeetingInput!) {
    meetings {
      meeting(id: $meetingId) {
        update(input: $input) {
          id
          title {
            translation(locale: "en")
          }
          startTime
          endTime
        }
      }
    }
  }
GRAPHQL

# Execute the mutation
result = Client.query(UpdateMeetingMutation, variables: {
  meetingId: "123",
  input: {
    attributes: {
      title: { en: "Updated Meeting Title" },
      startTime: "2025-11-01T14:00:00Z",
      endTime: "2025-11-01T16:00:00Z"
    }
  }
})

if result.data
  meeting = result.data.meetings.meeting.update
  puts "Meeting updated: #{meeting.id}"
else
  puts "Errors: #{result.errors.messages}"
end
```

## Field Reference

### typeOfMeeting Options
- `in_person` - Meeting is held in person
- `online` - Meeting is held online
- `hybrid` - Meeting is both in person and online

### registrationType Options
- `on_this_platform` - Registration is handled on the Decidim platform
- `on_different_platform` - Registration is handled on an external platform
- `registration_disabled` - No registration required

### iframeEmbedType Options
- `none` - No iframe embedding
- `embed_in_meeting_page` - Embed the online meeting in the meeting page
- `open_in_live_event_page` - Open in a separate live event page
- `open_in_new_tab` - Open in a new browser tab

### iframeAccessLevel Options
- `all` - Accessible to all users
- `registered` - Accessible to registered participants only
- `signed_in` - Accessible to signed-in users only

## Error Handling

The mutation will return a `GraphQL::ExecutionError` if:
- The user is not authorized to update the meeting
- The form validation fails (e.g., required fields missing)
- The meeting ID does not exist

Example error response:

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
      "message": "Title can't be blank, Start time can't be blank",
      "locations": [{"line": 3, "column": 9}],
      "path": ["meetings", "meeting", "update"]
    }
  ]
}
```

## Best Practices

1. **Always validate dates**: Ensure `startTime` is before `endTime`
2. **Handle time zones**: Use ISO 8601 format with time zone information
3. **Multilingual content**: Provide translations for all enabled locales
4. **Address validation**: Include complete address information with coordinates for in-person meetings
5. **Registration limits**: Set appropriate `availableSlots` for platform-based registrations
6. **Online meeting URLs**: Ensure URLs are valid and accessible for online/hybrid meetings

## Related Mutations

- `CreateMeeting` - Create a new meeting
- `WithdrawMeeting` - Withdraw an existing meeting

## Support

For more information, see the [Decidim API documentation](https://docs.decidim.org/develop/en/customize/graphql).
