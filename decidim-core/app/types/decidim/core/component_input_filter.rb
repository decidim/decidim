# frozen_string_literal: true

module Decidim
  module Core
    class ComponentInputFilter < BaseInputFilter
      include HasPublishableInputFilter
      include HasLocaleInputFilter

      graphql_name "ComponentFilter"
      description "A type used for filtering any component parent objects"

      argument :type,
               type: String,
               description: "Filters by type of component",
               required: false,
               prepare: ->(value, _ctx) do
                 { manifest_name: value.downcase }
               end
      argument :name,
               type: String,
               description: "Filters by name of the component, additional locale parameter can be provided to specify in which to search",
               required: false,
               prepare: ->(search, ctx) do
                          proc do |model_class, locale|
                            locale = ctx[:current_organization].default_locale if locale.blank?
                            op = Arel::Nodes::InfixOperation.new("->>", model_class.arel_table[:name], Arel::Nodes.build_quoted(locale))
                            op.matches("%#{search}%")
                          end
                        end
      argument :withGeolocationEnabled,
               type: Boolean,
               description: "Returns components with geolocation activated (may be Proposals or Meetings)",
               required: false,
               prepare: ->(active, _ctx) do
                 proc do |_model_class|
                   ["(settings->'global'->>'geocoding_enabled')::boolean is ? or manifest_name='meetings'", active]
                 end
               end
      argument :withCommentsEnabled,
               type: Boolean,
               description: "Returns components with comments enabled globally (can still be deactivated in the current step if the component has steps)",
               required: false,
               prepare: ->(active, _ctx) do
                 proc do |_model_class|
                   ["(settings->'global'->>'comments_enabled')::boolean is ?", active]
                 end
               end
    end
  end
end
