# Modules

Modules are subapplications that are run as application plugins.
They're used to define pieces of functionality that are pluggable to Decidim.

Decidim's modules are no more than Ruby on Rails engines that should be required in the application's `Gemfile`.

## Example

A typical engine looks like the following:

```ruby
module Decidim
  module Verifications
    module MyVerifier
      # This is an engine that authorizes users by doing a custom verification.
      class Engine < ::Rails::Engine
        isolate_namespace Decidim::Verifications::MyVerifier

        paths["db/migrate"] = nil
        paths["lib/tasks"] = nil

        routes do
          resource :authorizations, only: [:new, :create, :edit, :update], as: :authorization

          root to: "authorizations#new"
        end

        # This is a Dedicim::Verifications specific initializer
        initializer "decidim.my_verifier_verification_workflow" do |_app|
          Decidim::Verifications.register_workflow(:my_verifier) do |workflow|
            workflow.engine = Decidim::Verifications::MyVerifier::Engine
          end
        end

        # more initializers here...

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

