# Decidim::Verifications

Decidim offers several methods for allowing participants to get authorization to
perform certain privileged actions. This module implements several of those methods
and also offers a way for installation to implement their custom verification
methods.

## Introduction

Each decidim instance is in full control of its authorizations, and can customize:

* The different methods to be used by users to get verified. For example,
  through a census, by uploading their identity documents, or by receiving a
  verification home at their address.

* The different actions in decidim that require authorization, and which
  authorization method they require. For example, a decidim instance might
  choose to require census authorization to create proposals, but a fully
  verified address via a verification code sent by postal mail for voting on
  proposals.

## Types of authorization methods

Decidim implements two type of authorization methods:

* _Form authorizations_.

  When your verification method is simple enough, you can use a `Rectify::Form`
  to implement it. "Simple" here means that the authorization can be granted
  with the submission of a single form. For example, to validate a user against
  a census API you will need a form with some fields that your users will use to
  authenticate against a census (for example, an ID and a Postal Code). You'll
  implement this with a form class. See the documentation for the [parent
  class][authorization handler base class] or have a look at a
  [live example][live authorization handler example] in decidim-barcelona.

  To register your handler, use

  ```ruby
  # config/initializers/decidim.rb

  Decidim::Verifications.register_workflow(:census) do |workflow|
    workflow.form = "<myAuthorizationHandlerClass"
  end
  ```

* _Workflow authorizations_.

  For more complex scenarios requiring several steps or admin intervention, you
  can register a verification flow.

  For example:

  ```ruby
  # config/initializers/decidim.rb

  Decidim::Verifications.register_workflow(:sms_verification) do |workflow|
    workflow.engine = Decidim::Verifications::SmsVerification::Engine
    workflow.admin_engine = Decidim::Verifications::SmsVerification::AdminEngine
  end
  ```

  Inside these engines, you can implement any steps required for the
  authorization to succeed, via one or more custom controllers and views. You
  can create partial `Authorization` records (with the `verified_at` column set
  to `nil`) and hold partial verification data in the `verification_metadata`
  column, or even a partial verification attachment in the
  `verification_attachment` column.

  Decidim currently requires that your main engine defines two routes:

  * `new_authorization_path`: This is the entry point to start the authorization
    process.

  * `edit_authorization_path`: This is the entry point to resume an existing
    authorization process.

## Custom action authorizers

Custom action authorizers are an advanced component that can be used in both types of
authorization methods to customize some parts of the authorization process.
These are particulary useful when used within verification options, which are
set in the admin zone related to a component action. As a result, a verification
method will be allowed to change the authorization logic and the appearance based
on the context where the authorization is being performed.

For example, you can require authorization for supporting proposals in a participatory
process, and also restrict it to users with postal codes 12345 and 12346. The
[example authorization handler](https://github.com/decidim/decidim/blob/master/decidim-verifications/app/services/decidim/dummy_authorization_handler.rb)
included in this module allows to do that. As an admin user, you should visit
the proposals componenent permissions screen, choose the `Example authorization`
as the authorization handler name for the `vote` action and type something like
`{ allowed_postal_codes: ["12345", "12346"] }` in the `Options` field placed below.

You can override default behavior implementing a class that inherits form
`Decidim::Verifications::DefaultActionAuthorizer` and override some methods or that
implement its public methods:

* The `initialize` method receives the current authorization process context and
  saves it in local variables. This include the current authorization user state
  (an `Authorization` record) and permission `options` related to the action is
  trying to perform.

* The `authorize` method is responsible of evaluating the authorization process
  context and determine if the user authorization is `:ok` or in any other
  status.

* The `redirect_params` method allows to add additional query string parameters
  when redirecting to the authorization form. This is useful to send to the
  authorization form the permission `options` information that could be useful
  to adapt its behavior or appearance.

To be used by the verification method, this class should be referenced by name in
its workflow manifest:

```ruby
# config/initializers/decidim.rb

Decidim::Verifications.register_workflow(:sms_verification) do |workflow|
  workflow.engine = Decidim::Verifications::SmsVerification::Engine
  workflow.admin_engine = Decidim::Verifications::SmsVerification::AdminEngine
  workflow.action_authorizer = "Decidim::Verifications::SmsVerification::ActionAuthorizer"
end
```

Check the [example authorization handler](https://github.com/decidim/decidim/blob/master/decidim-verifications/app/services/decidim/dummy_authorization_handler.rb)
and the [DefaultActionAuthorizer class](https://github.com/decidim/decidim/blob/master/decidim-verifications/lib/decidim/verifications/default_action_authorizer.rb)
for additional technical details.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'decidim-verifications'
```

And then execute:

```bash
bundle
```

## Contributing

See [Decidim](https://github.com/decidim/decidim).

## License

See [Decidim](https://github.com/decidim/decidim).

[authorization handler base class]: https://github.com/decidim/decidim/blob/master/decidim-core/app/services/decidim/authorization_handler.rb
[real authorization handler]: https://github.com/decidim/decidim-barcelona/blob/master/app/services/census_authorization_handler.rb
