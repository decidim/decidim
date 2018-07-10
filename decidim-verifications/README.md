# Decidim::Verifications

Decidim offers several methods for allowing participants to get authorization to
perform certain privileged actions. This module implements several of those methods
and also offers a way for installation to implement their custom verification
methods.

There are several use cases for this, such as

* Sending a SMS code to users to verify that their have a valid cellphone

* Allowing users to upload a photo or scanned image of their identity document

* Sending users a code through postal code

* Allowing users to go to to a physical office and check their documentation

* Checking some information through other systems (as a Municipal Census on the
  case of Municipalities, Cities or Towns)

* Having a list of valid users emails

Right now Decidim supports only a few of these cases, but we have an internal
API where you can program your own kind of authorizations.

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
  class][authorization handler base class] or have a look at some live examples,
  such as:

  * [Decidim Barcelona].
  * [Decidim Terrassa].
  * [Decidim Sant Cugat].

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

## Authorization options

Sometimes you want to scope authorizations only to users that meet certain
requirements. For example, you might only allow users registered at a certain
postal code to be verified and thus perform certain actions.

You can do this with authorization options. For example, in the case just
presented, you should define something like this in your authorization workflow:

```ruby
Decidim::Verifications.register_workflow(:my_workflow) do |workflow|
  workflow.form = "MyAuthorizationHandler"

  workflow.options do |options|
    options.attribute :postal_code, type: :string, required: false
  end
end
```

The format of the options you can define is the standard for a virtus attribute,
plus an additional `required` (true by default) option were you can choose
whether the option is compulsory when configuring the workflow as a permission
for an action or not.

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
  (an `Authorization` record), permission `options` related to the action is
  trying to perform and the current `component` where the authorization is taking
  place.

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

[Decidim Barcelona]: https://github.com/AjuntamentdeBarcelona/decidim-barcelona/blob/master/app/services/census_authorization_handler.rb
[Decidim Terrassa]: https://github.com/AjuntamentDeTerrassa/decidim-terrassa/blob/master/app/services/census_authorization_handler.rb
[Decidim Sant Cugat]: https://github.com/AjuntamentdeSantCugat/decidim-sant_cugat/blob/master/app/services/census_authorization_handler.rb
