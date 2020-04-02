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

To publish an event to send a notification, Decidim's `EventManager` should be used:

```
# Note the convention between the `event` key, and the `event_class` that will be used later to wrap the payload and be used as the email or notification model.
data = {
  event: "decidim.events.comments.comment_created",
  event_class: Decidim::Comments::CommentCreatedEvent,
  resource: comment.root_commentable,
  extra: {
    comment_id: comment.id
  },
  affected_users: [user1, user2],
  followers: [user3, user4]
}

Decidim::EventsManager.publish(data)
```

Both, `EmailNotificationGenerator` and `NotificationGenerator` are use the same arguments:

- **event**: A String with the name of the event.
- **event_class**: A class that wraps the event.
- **resource**: an instance of a class implementing the `Decidim::Resource` concern.
- **followers**: a collection of Users that receive the notification because they're following it.
- **affected_users**: a collection of Users that receive the notification because they're affected by it
- **extra**: a Hash with extra information to be included in the notification.

Again, both generators will check for each user

- in the *followers* array, if she has the `notification_types` set to "all" or "followed-only".
- in the *affected_users* array, if she has the `notification_types` set to "all" or "own-only".

Event names must start with "decidim.events." (the `event` data key). This way `Decidim::EventPublisherJob` will automatically process them. Otherwise no artifact in Decidim will process them, and will be the developer's responsibility to subscribe to them and process.

Sometimes, when something that must be notified to users happen, a service is defined to manage the logic involved to decide which events should be published. See for example `Decidim::Comments::NewCommentNotificationCreator`.

Please refer to [Ruby on Rails Notifications documentation](https://api.rubyonrails.org/classes/ActiveSupport/Notifications.html) if you need to hack the Decidim's events system.

## How Decidim's `EventPublisherJob` processes the events?

The `EventPublisherJob` in Decidim's core engine subscribes to all notifications matching the regular expression `/^decidim\.events\./`. This is, starting with "decidim.events.". It will then be invoked when an imaginary event named "decidim.events.harmonica_blues" is published.

When invoked it simply performs some validations and enqueue an `EmailNotificationGeneratorJob` and a `NotificationGeneratorJob`.

The validations it performs check if the resource, the component, or the participatory space are published (when the concept applies to the artifact).

## The \*Event class

Generates the email and notification messages from the information related with the notification.

Event classes are subclasses of `Decidim::Events::SimpleEvent`.
A subset of the payload of the notification is passed to the event class's constructor:

- The `resource`
- The `event` name
- The notified user, either from the `followers` or from the `affected_users` arrays
- The `extra` hash, with content specific for the given SimpleEvent subclass
- The user_role, either :follower or :affected_user

With the previous information the event class is able to generate the following contents.

Developers will be able to customize those messages by adding translations to the `config/locales/en.yml` file of the corresponding module.
The keys to be used will have the translation scope corresponding to the event name ("decidim.events.comments.comment_by_followed_user" for example) and the key will be the content to override (email_subject, email_intro, etc.)

### Email contents

The following are the parts of the notification email:

- *email_subject*, to be customized
- email_greeting, with a good default, usually there's no need to cusomize it
- *email_intro*, to be customized
- *resource_text* (optional), rendered `html_safe` if present
- *resource_url*, a link to the involved resource if resource_url and resource_title are present
- *email_outro*

All contents except the `email_greeting` use to require customization on each notification.

### Notification contents

Only the `notification_title` is generated in the event class. The rest of the contents are produced by the templates from the `resource` and the `notification` objects.

## Testing notifications

- Test that the event has been published (usually a command test)
- Test the event returns the expected contents for the email and the notification.

Developers should we aware when adding URLs in the email's content, be sure to use absolute URLs and not relative paths.