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

  When your verification method is simple enough, you can use a `Decidim::Form`
  to implement it. "Simple" here means that the authorization can be granted
  with the submission of a single form. For example, to validate a user against
  a census API you will need a form with some fields that your users will use to
  authenticate against a census (for example, an ID and a Postal Code). You will
  implement this with a form class. See the documentation for the [parent
  class][authorization handler base class] or have a look at some live examples,
  such as:

  * [Decidim Barcelona].
  * [Decidim Terrassa].
  * [Decidim Sant Cugat].

  To register your handler, use

  ```ruby
  # config/initializers/decidim_verifications.rb

  Decidim::Verifications.register_workflow(:census) do |workflow|
    workflow.form = "<myAuthorizationHandlerClass>"
  end
  ```

* _Workflow authorizations_.

  For more complex scenarios requiring several steps or admin intervention, you
  can register a verification flow.

  For example:

  ```ruby
  # config/initializers/decidim_verifications.rb

  Decidim::Verifications.register_workflow(:my_verification) do |workflow|
    workflow.engine = Decidim::Verifications::MyVerification::Engine
    workflow.admin_engine = Decidim::Verifications::MyVerification::AdminEngine
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

* _Renewable authorizations_.
  By default a participant cannot renew its authorization, but this can be enabled when registering the workflow, the time between renewals can be configured (one day by default).

  Optionally to change the renew modal content part of the data stored, you can set a new value for the cell used to render the metadata.

  ```ruby
  # config/initializers/decidim_verifications.rb

  Decidim::Verifications.register_workflow(:census) do |workflow|
    workflow.form = "myAuthorizationHandlerClass"
    workflow.renewable = true
    workflow.time_between_renewals = 1.day
    workflow.metadata_cell = "decidim/verifications/authorization_metadata"
  end
  ```

### Identification numbers

For the verification of the participants' data in Verifications, you can configure which type of documents a participant can have. By default these documents are `identification_number` and `passport`, but in some countries you may need to adapt these to your region or governmental specific needs. For instance, in Spain there are `dni`, `nie` and `passport`.

For configuring these you can do so with the Environment Variable `VERIFICATIONS_DOCUMENT_TYPES`.

```env
VERIFICATIONS_DOCUMENT_TYPES="dni,nie,passport"
```

You need to also add the following keys in your i18n files (i.e. `config/locales/en.yml`). By default in the verifications, `identification_number` is currently being used as a universal example. Below are examples of adding `dni`, `nie` and `passport` locally used in Spain.

```yaml
en:
  decidim:
    verifications:
        id_documents:
          dni: DNI
          nie: NIE
          passport: Passport
```

### SMS verification

Decidim comes with a verification workflow designed to verify users by sending
an SMS to their mobile phone.

Much like a Census verification you just need to implement a class that sends an
SMS code using your preferred provider.

In order to setup Decidim with SMS verification you need to:

1. Create a class that accepts two parameters when initializing it (mobile phone and code) and a method named `deliver_code` that will send an SMS and return a truthy or falsey value if the delivery was OK or not.
1. Set the `sms_gateway_service` configuration variable to the name of the class that you just created (use a String, not the actual class) using the `DECIDIM_SMS_GATEWAY_SERVICE` environment variable

Keep in mind that Decidim will not store a free text version of the mobile phone, only a hashed
version so we can avoid duplicates and guarantee the users' privacy.

You can find an example [here][example SMS gateway].

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

The format of the options you can define is the standard for a Decidim attribute,
plus an additional `required` (true by default) option were you can choose
whether the option is compulsory when configuring the workflow as a permission
for an action or not.

## Custom action authorizers

Custom action authorizers are an advanced component that can be used in both types of
authorization methods to customize some parts of the authorization process.
These are particularly useful when used within verification options, which are
set in the admin zone related to a component action. As a result, a verification
method will be allowed to change the authorization logic and the appearance based
on the context where the authorization is being performed.

For example, you can require authorization for voting proposals in a participatory
process, and also restrict it to users with postal codes 12345 and 12346. The
[example authorization handler](https://github.com/decidim/decidim/blob/develop/decidim-generators/lib/decidim/generators/app_templates/dummy_authorization_handler.rb)
included in this module allows to do that. As an admin user, you should visit
the proposals component permissions screen, choose the `Example authorization`
as the authorization handler name for the `vote` action and enter "12345, 12346"
in the `Allowed postal codes` field placed below.

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
# config/initializers/decidim_verifications.rb

Decidim::Verifications.register_workflow(:my_verification) do |workflow|
  workflow.engine = Decidim::Verifications::MyVerification::Engine
  workflow.admin_engine = Decidim::Verifications::MyVerification::AdminEngine
  workflow.action_authorizer = "Decidim::Verifications::MyVerification::ActionAuthorizer"
end
```

Check the [example authorization handler](https://github.com/decidim/decidim/blob/develop/decidim-generators/lib/decidim/generators/app_templates/dummy_authorization_handler.rb)
and the [DefaultActionAuthorizer class](https://github.com/decidim/decidim/blob/develop/decidim-verifications/lib/decidim/verifications/default_action_authorizer.rb)
for additional technical details.

## How Handlers work

For a workflow to be visible in the user's profile, the organization must have
it in it is `available_authorizations` and the given handler must exist.
The name of the handler must match the authorization name plus the "Hander"
suffix. It also has to be in the `Decidim::Verifications` namespace.

The handler is both the Form object that the user must fill in order to be
verified, but also the validator of the filled information in order to grant the
authorization.

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

[authorization handler base class]: https://github.com/decidim/decidim/blob/develop/decidim-verifications/app/services/decidim/authorization_handler.rb
[example SMS gateway]: https://github.com/decidim/decidim/blob/develop/decidim-verifications/lib/decidim/verifications/sms/example_gateway.rb

[Decidim Barcelona]: https://github.com/AjuntamentdeBarcelona/decidim-barcelona/blob/master/app/services/census_authorization_handler.rb
[Decidim Terrassa]: https://github.com/AjuntamentDeTerrassa/decidim-terrassa/blob/master/app/services/census_authorization_handler.rb
[Decidim Sant Cugat]: https://github.com/AjuntamentdeSantCugat/decidim-sant_cugat/blob/master/app/services/census_authorization_handler.rb
