# frozen_string_literal: true

module Decidim
  module Core
    class BareComponentInputFilter < BaseInputFilter
      graphql_name "BareComponentFilter"
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
    end
  end
end
