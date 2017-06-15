# frozen_string_literal: true

module Decidim
  module Admin
    # This module includes helpers to show scopes in admin
    module ScopesHelper
      def scope_breadcrumbs(current_scope)
        current_scope.part_of_scopes.map do |scope|
          link_to translated_attribute(scope.name), scope_scopes_path(scope)
        end
      end

      def process_scopes_for_select(participatory_process)
        @process_scopes_for_select ||=
          if participatory_process
            participatory_process.top_scopes.map do |scope|
              [
                translated_attribute(scope.name),
                scope.id
              ]
            end
          else
            []
          end
      end

      def organization_scope_types(organization = current_organization)
        organization.scope_types.map do |scope_type|
          Struct.new(:id, :name).new(scope_type.id, translated_attribute(scope_type.name))
        end
      end
    end
  end
end
