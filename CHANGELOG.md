# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

### Added

### Changed

#### Automated authorization conflict handling for deleted users

In previous Decidim versions authorization conflicts (i.e. authorizing the user with the same unique data as a previous user) needed to be always handled manually. Now these are automatically handled for cases where the original user had authorized their account, then deleted their account and finally authorized the new account with the same details as the previous account.

This means that some participation data bound to the previous deleted user account is now automatically transferred over to the new account during the authorization process to prevent e.g. duplicate votes in budgeting votings. This includes any data that may or may not require an authorization through the component permissions because in Decidim we cannot be always perfectly sure when an authorization is required for the action or not. As an example, budget voting can start without an authorization and if the admin decides to configure an authorization for the component one day after the voting started, we need to assume that the all votes in that component required an authorization. Otherwise we would potentially allow multiple votes from the users that voted before the authorization was configured if they decided to create a new account to vote for a second time or deleted their original account and did that.

The transferred data can differ between the different modules but the official modules handle the following data automatically:

- **decidim-core**
  - Amendments (meaning any amendments for amendable records in different modules, such as proposals at `decidim-proposals`)
  - Coauthorships (meaning any coauthorable records in different modules, such as proposals and collaborative drafts at `decidim-proposals`)
  - Endorsements (for any records, e.g. blog posts at `decidim-blogs`, debates at `decidim-debates` and proposals at `decidim-proposals`)
- **decidim-blogs**
  - Blog posts
  - Endorsements for blog posts (through endorsement transfers at `decidim-core`)
- **decidim-budgets**
  - Budgeting votes (or orders as we call them in the code)
- **decidim-comments**
  - Comments
  - Comment votes
- **decidim-consultations**
  - Consultation votes
- **decidim-debates**
  - Debates
  - Endorsements for debates (through endorsement transfers at `decidim-core`)
- **decidim-elections**
  - Election votes
  - Election form answers (through form answer transfers at `decidim-forms`)
  - Feedback form answers (through form answer transfers at `decidim-forms`)
- **decidim-forms**
  - Form answers (for different forms, such as survey form answers at `decidim-surveys` or registration form answers at `decidim-meetings`)
- **decidim-initiatives**
  - Initiatives
  - Initiative votes/signatures
- **decidim-meetings**
  - Meetings
  - Meeting registrations
  - Meeting poll answers
  - Meeting registration form answers (through form answer transfers at `decidim-forms`)
- **decidim-proposals**
  - Proposal votes/supports
  - Proposals (through coauthorship transfers at `decidim-core`)
  - Collaborative drafts (through coauthorship transfers at `decidim-core`)
  - Proposal amendments (through amendment transfers at `decidim-core`)
  - Endorsements for proposals (through endorsement transfers at `decidim-core`)
- **decidim-surveys**
  - Survey form answers (through form answer transfers at `decidim-forms`)

If external modules need to transfer records between accounts during the authorization transfers, module developers can define the following initializer at their modules (note that coauthorable records are automatically already handled):

```ruby
module Decidim
  module YourModule
    class Engine < ::Rails::Engine
      # ...
      initializer "decidim_your_module.authorization_transfer" do
        Decidim::AuthorizationTransfer.register(:your_module) do |transfer, auth_hander|
          # Define the record class as the first argument to be moved to the
          # new user and the column name as the second argument that maps the
          # record to the original user. This will update all records that match
          # the old deleted account to the new user that was authorized using
          # conflicting authorization data. If you need access to the
          # authorization handler that caused the transfer to be initiated, it
          # is available as the second yielded argument (auth_hander).
          transfer.move_records(Decidim::YourModule::Foo, :decidim_author_id)
        end
      end
      # ...
    end
  end
end
```

By default you should handle transfer of all records that can require an authorization and leave instance implementers the possibility to disable those transfers if they want to as explained below.

If you would like to disable the authorization transfers feature altogether, you can define the following code in your application class located at `config/application.rb` of your instance:

```ruby
module DecidimYourCity
  class Application < Rails::Application
    # ...
    config.to_prepare do
      Decidim::AuthorizationTransfer.disable!
    end
    # ...
  end
end
```

Note that when the functionality is disabled, the authorization transfers work as they used to, i.e. a conflict is registered, admin users are notified about the conflict situation and the conflict needs to be manually handled.

If you would like to disable the authorization transfers only for specific modules, you can define the following code in your application class located at `config/application.rb` of your instance (pick only the modules you want to disable):

```ruby
module DecidimYourCity
  class Application < Rails::Application
    # ...
    config.after_initialize do
      Decidim::AuthorizationTransfer.unregister(:core) # any coauthorable records, e.g. proposals and collaborative drafts
      Decidim::AuthorizationTransfer.unregister(:blogs) # blog posts
      Decidim::AuthorizationTransfer.unregister(:budgets) # budgets
      Decidim::AuthorizationTransfer.unregister(:comments) # comments
      Decidim::AuthorizationTransfer.unregister(:consultations) # consultation votes
      Decidim::AuthorizationTransfer.unregister(:debates) # debates
      Decidim::AuthorizationTransfer.unregister(:elections) # elections
      Decidim::AuthorizationTransfer.unregister(:forms) # form answers, e.g. survey form answers or meeting registrations
      Decidim::AuthorizationTransfer.unregister(:initiatives) # initiatives and initiative votes/signatures
      Decidim::AuthorizationTransfer.unregister(:meetings) # meetings, meeting registrations and meeting poll answers
      Decidim::AuthorizationTransfer.unregister(:proposals) # proposal votes/supports

      # Or if you want to unregister multiple modules at once
      Decidim::AuthorizationTransfer.unregister(:blogs, :forms, :comments)
    end
    # ...
  end
end
```

Note that when unregistering an authorization transfer handler, the transfers will still work normally for the other transfer handlers and no conflicts are reported for the admin users in case of conflict situation between a new authorization and a previous authorization for a deleted user. In this case, the authorization is transferred to the new user normally but the unregistered transfer handlers are not called which means those records will not be transferred between the user accounts. For conflicts between normal registered users or managed users, the conflicts are still reported as before. The automated authorization transfers only happen in case the previously authorized conflicting user account was deleted.

You can read more about this change at PR [\#9463](https://github.com/decidim/decidim/pull/9463).

### Fixed

### Removed

## Previous versions

Please check [release/0.27-stable](https://github.com/decidim/decidim/blob/release/0.27-stable/CHANGELOG.md) for previous changes.
