# frozen_string_literal: true

module Decidim
  module Core
    class ComponentInputFilter < BaseInputFilter
      include HasPublishableInputFilter
      include HasLocalizedInputFilter

      graphql_name "ComponentFilter"
      description "A type used for filtering any component parent objects"

      argument :type,
               type: GraphQL::Types::String,
               description: "Filters by type of component",
               required: false,
               prepare: lambda { |value, _ctx|
                          { manifest_name: value.downcase }
                        }
      argument :name,
               type: GraphQL::Types::String,
               description: "Filters by name of the component, additional locale parameter can be provided to specify in which to search",
               required: false,
               prepare: lambda { |search, ctx|
                          lambda { |model_name, locale|
                            locale = ctx[:current_organization].default_locale if locale.blank?
                            op = Arel::Nodes::InfixOperation.new("->>", model_name.arel_table[:name], Arel::Nodes.build_quoted(locale))
                            op.matches("%#{search}%")
                          }
                        }

      argument :with_geolocation_enabled,
               type: GraphQL::Types::Boolean,
               description: "Returns components with geolocation activated (may be Proposals or Meetings)",
               required: false,
               prepare: lambda { |active, _ctx|
                          ->(_model_name, _locale) { ["(settings->'global'->>'geocoding_enabled')::boolean is ? or manifest_name='meetings'", active] }
                        }

      argument :with_comments_enabled,
               type: GraphQL::Types::Boolean,
               description: "Returns components with comments enabled globally (can still be deactivated in the current step if the component has steps)",
               required: false,
               prepare: lambda { |active, _ctx|
                          ->(_model_name, _locale) { ["(settings->'global'->>'comments_enabled')::boolean is ?", active] }
                        }
    end
  end
end
