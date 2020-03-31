# Notifications

In Decidim, notifications may mean two things:

- he concept of notifying an event to a user. This is the wider use of "notification".
- the notification's participant space, which lists the `Decidim::Notification`s she has received.

So, in the wider sense, notifications are messages that are sent to the users, admins or participants, when something interesting occurs in the platform.

Each notification is sent via two communication channels: email and 

## A Decidim Event

Technically, a Decidim event is nothing but an `ActiveSupport::Notification` with a payload of the form

```
ActiveSupport::Notifications.publish(
  event,
  event_class: event_class.name,
  resource: resource,
  affected_users: affected_users.uniq.compact,
  followers: followers.uniq.compact,
  extra: extra
)
```

To publish one, Decidim's `EventManager` should be used:

```
# Note the convention between the `event` key, and the `event_class` that will be used later to wrap the payload and be used as the email or notification model.
event_class = "Decidim::Comments::#{event.to_s.camelcase}Event".constantize
data = {
  event: "decidim.events.comments.#{event}",
  event_class: event_class,
  resource: comment.root_commentable,
  extra: {
    comment_id: comment.id
  },
  followers: [user1, user2]
}


Decidim::EventsManager.publish(data)
```

Events must start with the "decidim.events." name (the `event` data key). This way `Decidim::EventPublisherJob` will automatically process them. Otherwise no artifact in Decidim will process them, and will be the developer's responsibility to subscribe to them and process.

Sometimes, when something that must be notified to users happen, a service is defined to manage the logic involved to decide which events should be published. See for example `Decidim::Comments::NewCommentNotificationCreator`.

Please refer to [Ruby on Rails Notifications documentation](https://api.rubyonrails.org/classes/ActiveSupport/Notifications.html) if you need to hack the Decidim's events system.

## How Decidim's `EventPublisherJob` processes the events?

The `EventPublisherJob` in Decidim's core engine subscribes to all notifications matching the regular expression `/^decidim\.events\./`. This is, starting with "decidim.events.". It will then be invoked when an imaginary event named "decidim.events.harmonica_blues" is published.

When invoked it simply performs some validations and enqueue an `EmailNotificationGeneratorJob` and a `NotificationGeneratorJob`.

The validations it performs check if the resource, the component, or the participatory space are published (when the concept applies to the artifact).
