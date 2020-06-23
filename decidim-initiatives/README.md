# Decidim::Initiatives

Initiatives is the place on Decidim's where citizens can promote a civic initiative. Unlike
participatory processes that must be created by an administrator, Civic initiatives can be
created by any user of the platform.

An initiative will contain attachments and comments from other users as well.

Prior to be published an initiative must be technically validated. All the validation
process and communication between the platform administrators and the sponsorship
committee is managed via an administration UI.

## Creating an initiative

A user views the Initiatives page at `/initiatives`. If she is allowed to create an
initiative and she belongs to a group, she will see a call-to-action button: `New initiative`.

If there is more than one type of initiative, she will have to choose one and go through
several screens to help her refine the initiative.
Once created, the initiative is not yet published.

The user must then edit her initiative and click the "Send for technical validation"
button, which looks greyed out but can be clicked. Then it's sent to the site admins to
review; once reviewed they can publish the initiative.

At that point the initiative will display on the site.

### Determining if a user can create an initiative

A participant can [create an initiative if](https://github.com/decidim/decidim/blob/develop/decidim-initiatives/app/permissions/decidim/initiatives/permissions.rb#L76-L79)
Initiatives creation is enabled, and one of:
* `Decidim::Initiatives.do_not_require_authorization = true` is set (see below), or
* they have admin permissions on a group, or
* they have been individually authorized to do so

### Components

Once an initiative has been created it gets the Meetings and Page component enabled by
default. The initiative author has no control over these - an admin will need to manage
them. All of the other usual components may be added by an admin too.

### Initiative types

For a user to create an initiative, at least one initiative type needs to be created. An
initiative type should have one or more scopes, each one is configured with the amount of
signatures required.

There are a number of ways in which signatures can be collected:
* online
* in person
* mixed

A PDF export of signatures is available.

#### Promotion committee

An initiative type can optionally be supported by a promotion committee, with a minimum
number of committee members. Once the user has created the initiative and before it can be
sent for technical validation they need to invite committee members to promote it.

When the user has created the initiative they will be given a link to share with possible
committee members, which will look something like `/initiatives/.../committee_requests/new`

When a prospective committee member opens the link, they can click a button which allows
them to request to be part of the committee. The initiative author then needs to approve
each request, by opening the Admin Dashboard link in the user menu, editing their
initiative, clicking "Committee members" and then approving each member.

Once enough people have joined the promoter committee the initiative author can send it for
technical validation.

## Usage

This plugin provides:

* A CRUD engine to manage initiatives.
* Public views for initiatives via a high level section in the main menu.
* An admin dashboard for the initiative author
* An admin dashboard for an initiative's promotion committee

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'decidim-initiatives'
```

And then execute:

```bash
bundle
bundle exec rails decidim_initiatives:install:migrations
bundle exec rails db:migrate
```

## Database

The database requires the extension pg_trgm enabled. Contact your DBA to enable it.

```sql
CREATE EXTENSION pg_trgm;
```

## Deactivating authorization requirement and other module settings

Some of the settings of the module need to be set in the code of your app, for example in the file `config/initializers/decidim.rb`.

This is the case if you want to enable the creation of initiatives even when no authorization method is set.

Just use the following line:
```
Decidim::Initiatives.do_not_require_authorization = true
```

All the settings and their default values which can be overriden can be found in the file [`lib/decidim/initiatives.rb`](https://github.com/decidim/decidim/blob/master/decidim-initiatives/lib/decidim/initiatives.rb).

For example, you can also change the minimum number of required committee members to 1 (default is 2) by adding this line:
```
Decidim::Initiatives.minimum_committee_members = 1
```
Or change the number of days given to gather signatures to 365 (default is 120) with:
```
Decidim::Initiatives.default_signature_time_period_length = 365
```

## Rake tasks

This engine comes with three rake tasks that should be executed on daily basis. The best
way to execute these tasks is using cron jobs. You can manage this cron jobs in your
Rails application using the [Whenever GEM](https://github.com/javan/whenever) or even
creating them by hand.

### decidim_initiatives:check_validating

This task move all initiatives in validation phase without changes for the amount of
time defined in __Decidim::Initiatives::max_time_in_validating_state__. These initiatives
will be moved to __discarded__ state.

### decidim_initiatives:check_published

This task retrieves all published initiatives whose support method is online and the support
period has expired. Initiatives that have reached the minimum supports required will pass
to state __accepted__. The initiatives without enough supports will pass to __rejected__ state.

Initiatives with offline support method enabled (pure offline or mixed) will get its status updated
after the presential supports have been registered into the system.

### decidim_initiatives:notify_progress

This task sends notification mails when initiatives reaches the support percentages defined in
__Decidim::Initiatives.first_notification_percentage__ and __Decidim::Initiatives.second_notification_percentage__.

Author, members of the promoter committee and followers will receive it.

## Exporting online signatures

When the signature method is set to any or face to face it may be necessary to implement
a mechanism to validate that there are no duplicated signatures. To do so the engine provides
a functionality that allows exporting the online signatures to validate them against physical
signatures.

The signatures are exported as a hash string in order to preserve the identity of the signer together with her privacy.
Each hash is composed with the following criteria:

* Algorithm used: SHA1
* Format of the string hashed: "#{unique_id}#{title}#{description}"

There are some considerations that you must keep in mind:

* Title and description will be hashed using the same format included in the database, this is including html tags.
* Title and description will be hashed using the same locale used by the initiative author. In case there is more
  than one locale available be sure that you change your locale settings to be inline with
  the locale used to generate the hashes outside Decidim.

## Seeding example data

In order to populate the database with example data proceed as usual in rails:

```bash
bundle exec rails db:seed
```

## Aditional considerations

### Cookies

This engine makes use of cookies to store large form data. You should change the
default session store or you might experience problems.

Check the [Rails configuration guide](http://guides.rubyonrails.org/configuring.html#rails-general-configuration)
in order to get instructions about changing the default session store.

## Contributing

See [Decidim](https://github.com/decidim/decidim).

## License

See [Decidim](https://github.com/decidim/decidim).
