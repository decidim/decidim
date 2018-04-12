# frozen_string_literal: true

module Decidim
  module Core
    # This type represents a Decidim's global property.
    DecidimType = GraphQL::ObjectType.define do
      name "Decidim"
      description "Decidim's framework-related properties."

      field :version, !types.String, "The current decidim's version of this deployment." do
        resolve ->(obj, _args, _ctx) { obj.version }
      end

      field :applicationName, !types.String, "The current installation's name." do
        resolve ->(obj, _args, _ctx) { obj.application_name }
      end

      field :rubyVersion, !types.String, "The current ruby version" do
        resolve ->(_, _, _) { RUBY_VERSION }
      end
    end
  end
end
