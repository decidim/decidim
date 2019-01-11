# Modules

Modules are subapplications that are run as application plugins.
They're used to define pieces of functionality that are pluggable to Decidim.

Decidim's modules are no more than Ruby on Rails engines that should be required in the application's `Gemfile`.

## Example

A typical engine looks like the following:

```ruby
module Decidim
  module Verifications
    module Sms
      # This is an engine that authorizes users by sending them a code through an SMS.
      class Engine < ::Rails::Engine
        isolate_namespace Decidim::Verifications::Sms

        paths["db/migrate"] = nil
        paths["lib/tasks"] = nil

        routes do
          resource :authorizations, only: [:new, :create, :edit, :update], as: :authorization

          root to: "authorizations#new"
        end

        initializer "decidim.sms_verification_workflow" do |_app|
          if Decidim.sms_gateway_service
            Decidim::Verifications.register_workflow(:sms) do |workflow|
              workflow.engine = Decidim::Verifications::Sms::Engine
            end
          end
        end
      end
    end
  end
end
```

It is a standard Ruby on Rails engine.

## Decidim gotchas with engines

If you have an external module that defines rake tasks and more than one
engine, you probably want to add `paths["lib/tasks"]= nil` to all engines but
the main one, otherwise the tasks you define are probably running multiple
times unintentionally. Check #3892 for more details.

