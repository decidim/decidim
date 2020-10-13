# OAuth

Decidim is both and OAuth client (via [omniauth](https://github.com/omniauth/omniauth)) and an OAuth provider (via [doorkeeper](https://github.com/doorkeeper-gem/doorkeeper)).

Check the [Social Providers](https://github.com/decidim/decidim/blob/master/docs/services/social_providers.md) document to check the provider and client configurations.

## Performing more actions on omniauth registration

Some times, there is the need to perform more actions than just creating a user on registration, this is why `CreateOmniauthRegistration` command publishes a `"decidim.user.omniauth_registration` event after registration so that developers can subscribe to it and perform other actions like user verification or alike.

This event comes with the following payload:

* user_id: The id for the registered User.
* identity_id: The id for the social Identity.
* provider: The name for the social provider.
* uid: OAuth's uid
* email: User's email.
* name: User's name.
* nickname: User's nickname after being normalized.
* avatar_url: Avatar's url, if any.
* raw_data: The raw hash received directly from the Omniauth gem.

To be notified after a registration one should subscribe to the event, in the passed block the after registration code should be implemented:

```ruby
ActiveSupport::Notifications.subscribe "decidim.user.omniauth_registration" do |name, started, finished, unique_id, data|
  puts "the data: #{data.inspect}"
  IdCatMobilVerificationJob.perform_later(data[:raw_data])
end
```

It is a good practice to delegate the required implementation to a Job to bring a fastest response to the user, also it will avoid that crashes in this code to propagate to the registration process.
