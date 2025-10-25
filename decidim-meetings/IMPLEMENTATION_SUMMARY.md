# CreateMeeting Mutation - Implementation Summary

## Overview

This implementation adds a GraphQL mutation to create meetings in the decidim-meetings module through the Decidim API.

## What Was Created

### Core Mutation Files
1. **CreateMeetingAttributes** (`decidim-meetings/lib/decidim/api/mutations/create_meeting_attributes.rb`)
   - Defines all input parameters for creating a meeting
   - 18 arguments covering all aspects of meeting creation
   - Required fields: title, description, startTime, endTime, typeOfMeeting, registrationType
   - Optional fields: location, coordinates, URLs, registration details, taxonomies

2. **CreateMeetingType** (`decidim-meetings/lib/decidim/api/mutations/create_meeting_type.rb`)
   - Main mutation class handling the meeting creation logic
   - Validates component exists and is a meetings component
   - Builds form from input attributes
   - Calls existing `Decidim::Meetings::CreateMeeting` command
   - Returns created meeting or validation errors
   - Includes authorization checks

3. **MeetingsMutationType** (`decidim-meetings/lib/decidim/api/mutations/meetings_mutation_type.rb`)
   - Component-level wrapper exposing the createMeeting mutation
   - Extends `Decidim::Core::ComponentType` for proper authorization
   - Registered in the MutationRegistry for automatic GraphQL schema integration

### Integration Points
4. **API Loader** (`decidim-meetings/lib/decidim/meetings/api.rb`)
   - Added autoload statements for all three mutation classes

5. **Engine Registration** (`decidim-meetings/lib/decidim/meetings/engine.rb`)
   - Added initializer to register MeetingsMutationType in the MutationRegistry
   - Ensures mutations are available in the GraphQL schema

### Testing
6. **Spec File** (`decidim-meetings/spec/lib/decidim/api/mutations/create_meeting_type_spec.rb`)
   - Comprehensive test coverage including:
     - Successful meeting creation
     - Validation error handling
     - Authorization checks
     - Component validation
     - Invalid attribute handling

### Documentation
7. **Usage Guide** (`decidim-meetings/CREATE_MEETING_MUTATION.md`)
   - Complete GraphQL schema documentation
   - Detailed description of all input fields
   - 4 complete usage examples:
     * Online meeting with platform registration
     * In-person meeting
     * Hybrid meeting with categories
     * Meeting with external registration
   - Error handling documentation
   - Authorization requirements

## How To Use The Mutation

### Basic Structure

The mutation is accessed through the component mutation interface:

```graphql
mutation {
  component(id: COMPONENT_ID) {
    ... on MeetingsMutation {
      createMeeting(
        attributes: { ... }
      ) {
        # Meeting fields to return
      }
    }
  }
}
```

### Complete Example

```graphql
mutation CreateOnlineMeeting {
  component(id: 123) {
    ... on MeetingsMutation {
      createMeeting(
        attributes: {
          title: "Community Planning Session"
          description: "Join us for our monthly planning session"
          typeOfMeeting: "online"
          startTime: "2024-12-01T14:00:00Z"
          endTime: "2024-12-01T16:00:00Z"
          onlineMeetingUrl: "https://meet.example.com/planning"
          registrationType: "on_this_platform"
          availableSlots: 100
          registrationTerms: "Please be on time"
          iframeEmbedType: "embed_in_meeting_page"
          iframeAccessLevel: "registered"
        }
      ) {
        id
        title { translation(locale: "en") }
        description { translation(locale: "en") }
        startTime
        endTime
        typeOfMeeting
        onlineMeetingUrl
        registrationsEnabled
        remainingSlots
        url
      }
    }
  }
}
```

## Required Fields

Minimum required fields to create a meeting:
- `title` - Meeting title
- `description` - Meeting description  
- `startTime` - When the meeting starts (ISO 8601 format)
- `endTime` - When the meeting ends (ISO 8601 format)
- `typeOfMeeting` - One of: "online", "in_person", "hybrid"
- `registrationType` - One of: "on_this_platform", "on_different_platform", "registration_disabled"

Additional requirements based on meeting type:
- **online** or **hybrid**: Must provide `onlineMeetingUrl`
- **in_person** or **hybrid**: Should provide `location`
- **on_this_platform** registration: Must provide `availableSlots` and `registrationTerms`
- **on_different_platform** registration: Must provide `registrationUrl`

## Authorization

To use this mutation, you need:
1. Valid user authentication (logged in)
2. OAuth scopes: `api:read` and `api:write`
3. Permission to create meetings in the component (typically granted to participants)

## What Happens When You Create a Meeting

The mutation:
1. Validates the component exists and is a meetings component
2. Checks user authorization
3. Validates all input fields using `Decidim::Meetings::MeetingForm`
4. Creates the meeting using the existing `CreateMeeting` command
5. Automatically publishes the meeting
6. Makes the creator follow the meeting
7. Sends notifications to participatory space followers
8. Schedules upcoming meeting notifications (if in the future)
9. Returns the created meeting object

## Error Handling

The mutation returns errors for:
- Component not found: `"Component not found"`
- Wrong component type: `"Invalid component type. Must be a meetings component."`
- Validation errors: Lists all validation failures, e.g., `"Title can't be blank, End time must be after start time"`
- Authorization errors: Handled by GraphQL authorization layer

## Testing Your Mutation

You can test using:
1. **GraphiQL** - Built-in GraphQL IDE at `/api/graphiql`
2. **HTTP POST** to `/api` endpoint with proper authentication
3. **Ruby console** in development environment

Example curl request:
```bash
curl -X POST https://your-decidim-instance.org/api \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d '{
    "query": "mutation { component(id: 123) { ... on MeetingsMutation { createMeeting(attributes: { title: \"Test\", description: \"Test\", typeOfMeeting: \"online\", startTime: \"2024-12-01T14:00:00Z\", endTime: \"2024-12-01T16:00:00Z\", onlineMeetingUrl: \"https://meet.test\", registrationType: \"registration_disabled\" }) { id title { translation(locale: \"en\") } } } } }"
  }'
```

## Supported Meeting Types

### Online Meeting
```graphql
typeOfMeeting: "online"
onlineMeetingUrl: "https://zoom.us/j/123456789"
registrationType: "on_this_platform" # or others
```

### In-Person Meeting
```graphql
typeOfMeeting: "in_person"
location: "City Hall"
address: "123 Main St"
latitude: 40.7128
longitude: -74.0060
registrationType: "registration_disabled" # or others
```

### Hybrid Meeting
```graphql
typeOfMeeting: "hybrid"
location: "Conference Center"
onlineMeetingUrl: "https://teams.microsoft.com/meeting"
registrationType: "on_this_platform" # or others
```

## Next Steps

For more detailed examples and complete field descriptions, see:
- `CREATE_MEETING_MUTATION.md` in the decidim-meetings directory
- GraphQL schema documentation at `/api/graphiql`
- Decidim API documentation at https://docs.decidim.org

## Technical Notes

- The mutation uses the existing `Decidim::Meetings::CreateMeeting` command, ensuring consistency with UI-based meeting creation
- All validations from `Decidim::Meetings::MeetingForm` are applied
- Translatable fields (title, description, location, etc.) are stored in the current user's locale
- Taxonomy associations support categorizing meetings
- The implementation follows Decidim's established patterns for API mutations
