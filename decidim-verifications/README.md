# Decidim::Verifications

Decidim offers several methods for allowing participants to get authorization to
perform certain priviledge actions. This gem implements several of those methods
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

  To register your handler, you'll need to reference it from the Decidim
  initializer:

  ```ruby
  # config/initializers/decidim.rb

  config.authorization_handlers = ["<my authorization handler class>"]
  ```

* _Workflow authorizations_.

  For more complex scenarios requiring several steps or admin intervention, you
  can register a verification flow.

  For example:

  ```ruby
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
