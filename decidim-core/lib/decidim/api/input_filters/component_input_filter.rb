# frozen_string_literal: true

module Decidim
  module Core
    class ComponentInputFilter < BaseInputFilter
      include HasPublishableInputFilter
      include HasLocalizedInputFilter

      graphql_name "ComponentFilter"
      description "A type used for filtering any component parent objects"

      argument :name,
               type: GraphQL::Types::String,
               description: "Filters by name of the component, additional locale parameter can be provided to specify in which to search",
               required: false,
               prepare: :prepare_name

      argument :type,
               type: GraphQL::Types::String,
               description: "Filters by type of component",
               required: false,
               prepare: :prepare_type

      argument :with_geolocation_enabled,
               type: GraphQL::Types::Boolean,
               description: "Returns components with geolocation activated (may be Proposals or Meetings)",
               required: false,
               prepare: :prepare_geolocation_enabled

      argument :with_comments_enabled,
               type: GraphQL::Types::Boolean,
               description: "Returns components with comments enabled globally (can still be deactivated in the current step if the component has steps)",
               required: false,
               prepare: :prepare_comments_enabled

      def self.prepare_comments_enabled(active, _ctx)
        lambda do |_model_name, _locale|
          # ["settings->'global'->>'comments_enabled' = ?", Arel.sql(active)]
          ["settings @> ?", { global: { comments_enabled: active } }.to_json]
        end
      end

      def self.prepare_geolocation_enabled(active, _ctx)
        lambda do |_model_name, _locale|
          ["settings @> ? or manifest_name='meetings'", { global: { geocoding_enabled: active } }.to_json]
        end
      end

      def self.prepare_name(search, ctx)
        lambda do |model_name, locale|
          locale = ctx[:current_organization].default_locale if locale.blank?
          op = Arel::Nodes::InfixOperation.new("->>", model_name.arel_table[:name], Arel::Nodes.build_quoted(locale))
          op.matches("%#{search}%")
        end
      end

      def self.prepare_type(value, _ctx)
        { manifest_name: value.underscore }
      end
    end
  end
end
