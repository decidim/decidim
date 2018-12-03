# OAuth

Decidim is both and OAuth client (via [omniauth](https://github.com/omniauth/omniauth)) and an OAuth provider (via [doorkeeper](https://github.com/doorkeeper-gem/doorkeeper)).

Check the [Social Providers](https://github.com/decidim/decidim/blob/master/docs/services/social_providers.md) document to check the client configuration.

## Decidim as an OAuth provider

You can use your own Decidim application to log in to other applications that support OAuth 2. To do it you need to create an OAuth application from the admin panel for each client that wants to use Decidim.

To create a new OAuth application you need:

* Name: The name of the client application that will be shown to the user when authorizing it from your Decidim application.
* Redirect URI: The URI where the Decidim application should redirect the user after authorizing it. It is usually where you handle the OAUth callback in your client application. If you're using `omniauth-decidim` the value should be `YOUR_APPLICATION_HOST/users/auth/decidim/callback`.
* Organization name: The name of the organization that owns the client application.
* Organization URL: The URL of the organization that owns the client application.
* Organization logo: An image of the logo of the organization that owns the client application.

All the organization data will be used during the authorization process so the users know to who they're giving their data.

Once you've created your application you'll get the settings to setup your client.

Check [omniauth-decidim](https://github.com/decidim/omniauth-decidim) in order to configure your client application.

## Performing more actions on omniauth registration

Some times, there is the need to perform more actions than just ceating a user on registration, this is why `CreateOmniauthRegistration` command publishes a `"decidim.events.user.omniauth_registration` event after registration so that developers can subscribe to it and perform other actions like user verification or alike.

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
ActiveSupport::Notifications.subscribe "decidim.events.user.omniauth_registration" do |name, started, finished, unique_id, data|
  puts "the data: #{data.inspect}"
  IdCatMobilVerificationJob.perform_later(data[:raw_data])
end
```

It is a good practice to delegate the required implementation to a Job to bring a fastest response to the user, also it will avoid that crashes in this code to propagate to the registration process.
