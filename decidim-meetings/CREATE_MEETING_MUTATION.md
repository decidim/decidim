# CreateMeeting GraphQL Mutation

This mutation allows you to create a new meeting through the Decidim API.

## Mutation Definition

The `createMeeting` mutation is available for meetings components and requires authentication with appropriate permissions.

## GraphQL Schema

```graphql
mutation {
  createMeeting(
    componentId: ID!
    attributes: MeetingAttributes!
  ) {
    # Returns a Meeting object
    id
    title { translation(locale: "en") }
    description { translation(locale: "en") }
    location { translation(locale: "en") }
    locationHints { translation(locale: "en") }
    startTime
    endTime
    typeOfMeeting
    registrationType
    onlineMeetingUrl
    # ... other Meeting fields
  }
}
```

## Input Attributes

### Required Fields

- `title` (String): The title of the meeting
- `description` (String): The description of the meeting
- `startTime` (DateTime): When the meeting starts (ISO 8601 format)
- `endTime` (DateTime): When the meeting ends (ISO 8601 format)
- `typeOfMeeting` (String): Must be one of: `"online"`, `"in_person"`, or `"hybrid"`
- `registrationType` (String): Must be one of: `"on_this_platform"`, `"on_different_platform"`, or `"registration_disabled"`

### Optional Fields

- `location` (String): Physical location of the meeting (required for `in_person` and `hybrid` meetings)
- `locationHints` (String): Additional hints about the location
- `address` (String): Full address of the meeting venue
- `latitude` (Float): Latitude coordinate
- `longitude` (Float): Longitude coordinate
- `onlineMeetingUrl` (String): URL for the online meeting (required for `online` and `hybrid` meetings)
- `registrationUrl` (String): External registration URL (when using `on_different_platform`)
- `availableSlots` (Int): Number of available registration slots (for `on_this_platform`)
- `registrationTerms` (String): Terms and conditions for registration (required for `on_this_platform`)
- `iframeEmbedType` (String): How to display the online meeting. Options: `"none"`, `"embed_in_meeting_page"`, `"open_in_live_event_page"`, `"open_in_new_tab"`
- `iframeAccessLevel` (String): Who can access the iframe. Options: `"all"`, `"registered"`, `"signed_in"`
- `taxonomyIds` ([ID]): Array of taxonomy IDs to categorize the meeting

## Full Example Request

### Example 1: Create an Online Meeting with Registration

```graphql
mutation {
  createMeeting(
    componentId: 123,
    attributes: {
      title: "Community Planning Session",
      description: "Join us for our monthly community planning session where we discuss upcoming initiatives and gather feedback.",
      typeOfMeeting: "online",
      startTime: "2024-12-01T14:00:00Z",
      endTime: "2024-12-01T16:00:00Z",
      onlineMeetingUrl: "https://meet.example.com/community-planning",
      registrationType: "on_this_platform",
      availableSlots: 100,
      registrationTerms: "By registering, you agree to participate constructively and follow our community guidelines.",
      iframeEmbedType: "embed_in_meeting_page",
      iframeAccessLevel: "registered"
    }
  ) {
    id
    title { translation(locale: "en") }
    startTime
    endTime
    typeOfMeeting
    registrationsEnabled
    remainingSlots
    url
  }
}
```

### Example 2: Create an In-Person Meeting

```graphql
mutation {
  createMeeting(
    componentId: 123,
    attributes: {
      title: "Town Hall Meeting",
      description: "Annual town hall meeting to discuss budget priorities.",
      typeOfMeeting: "in_person",
      location: "City Hall, Main Auditorium",
      locationHints: "Enter through the main entrance, auditorium is on the second floor.",
      address: "123 Main Street, Cityville, ST 12345",
      latitude: 40.7128,
      longitude: -74.0060,
      startTime: "2024-11-15T18:00:00Z",
      endTime: "2024-11-15T20:00:00Z",
      registrationType: "registration_disabled"
    }
  ) {
    id
    title { translation(locale: "en") }
    location { translation(locale: "en") }
    coordinates {
      latitude
      longitude
    }
    startTime
    endTime
  }
}
```

### Example 3: Create a Hybrid Meeting with Categories

```graphql
mutation {
  createMeeting(
    componentId: 123,
    attributes: {
      title: "Strategic Planning Workshop",
      description: "Hybrid workshop for strategic planning. Attend in person or join online.",
      typeOfMeeting: "hybrid",
      location: "Innovation Center, Room 301",
      locationHints: "Parking available in the adjacent lot.",
      address: "456 Tech Boulevard, Innovation District",
      latitude: 37.7749,
      longitude: -122.4194,
      onlineMeetingUrl: "https://zoom.us/j/123456789",
      startTime: "2024-12-15T09:00:00Z",
      endTime: "2024-12-15T12:00:00Z",
      registrationType: "on_this_platform",
      availableSlots: 50,
      registrationTerms: "Registration is required for both in-person and online attendance.",
      iframeEmbedType: "open_in_new_tab",
      iframeAccessLevel: "registered",
      taxonomyIds: [45, 67]  # Category IDs for "Strategic Planning" and "Workshops"
    }
  ) {
    id
    title { translation(locale: "en") }
    description { translation(locale: "en") }
    typeOfMeeting
    location { translation(locale: "en") }
    onlineMeetingUrl
    registrationsEnabled
    taxonomies {
      id
      name { translation(locale: "en") }
    }
  }
}
```

### Example 4: Create Meeting with External Registration

```graphql
mutation {
  createMeeting(
    componentId: 123,
    attributes: {
      title: "Conference Workshop",
      description: "Special workshop session at our annual conference.",
      typeOfMeeting: "online",
      onlineMeetingUrl: "https://teams.microsoft.com/meeting/xyz",
      startTime: "2024-12-20T15:00:00Z",
      endTime: "2024-12-20T17:00:00Z",
      registrationType: "on_different_platform",
      registrationUrl: "https://eventbrite.com/event/12345"
    }
  ) {
    id
    title { translation(locale: "en") }
    registrationType
    registrationUrl
    url
  }
}
```

## Response

On success, the mutation returns the created Meeting object with all requested fields.

```json
{
  "data": {
    "createMeeting": {
      "id": "789",
      "title": {
        "translation": "Community Planning Session"
      },
      "startTime": "2024-12-01T14:00:00Z",
      "endTime": "2024-12-01T16:00:00Z",
      "typeOfMeeting": "online",
      "registrationsEnabled": true,
      "remainingSlots": 100,
      "url": "https://your-decidim-instance.org/processes/slug/f/123/meetings/789"
    }
  }
}
```

## Error Handling

The mutation will return a GraphQL error in the following cases:

1. **Component not found**: When the specified `componentId` doesn't exist
   ```json
   {
     "errors": [{
       "message": "Component not found"
     }]
   }
   ```

2. **Invalid component type**: When the component is not a meetings component
   ```json
   {
     "errors": [{
       "message": "Invalid component type. Must be a meetings component."
     }]
   }
   ```

3. **Validation errors**: When the meeting attributes fail validation
   ```json
   {
     "errors": [{
       "message": "Title can't be blank, End time must be after start time"
     }]
   }
   ```

4. **Authorization errors**: When the user doesn't have permission to create meetings
   ```json
   {
     "errors": [{
       "message": "You are not authorized to perform this action"
     }]
   }
   ```

## Authorization Requirements

To use this mutation, you must:

1. Be authenticated (have a valid user session)
2. Have the `api:read` and `api:write` OAuth scopes
3. Have permission to create meetings in the specified component

Permissions are typically granted to:
- Users who are allowed to create meetings in public (participant-created meetings)
- Administrators of the participatory space

## Notes

- The meeting is automatically published upon creation
- The creating user automatically follows the meeting
- Notifications are sent to followers of the participatory space
- If the meeting starts in the future, an upcoming meeting notification is scheduled
- All translatable fields (title, description, location, locationHints, registrationTerms) are stored in the current locale
- The meeting must pass all form validations defined in `Decidim::Meetings::MeetingForm`

## Related Documentation

- [Decidim Meetings Module Documentation](https://docs.decidim.org/en/develop/modules/meetings/)
- [Decidim GraphQL API Documentation](https://docs.decidim.org/en/develop/api/)
- [Meeting Types Reference](https://docs.decidim.org/en/develop/modules/meetings/meeting_types/)
