# frozen_string_literal: true

module Decidim
  module Admin
    # This module includes helpers to show scopes in admin
    module ScopesHelper
      Option = Struct.new(:id, :name)

      # Public: This helper shows the path to the given scope, linking each ancestor.
      #
      # current_scope - Scope object to show
      #
      def scope_breadcrumbs(current_scope)
        current_scope.part_of_scopes.map do |scope|
          if scope == current_scope
            translated_attribute(scope.name)
          else
            link_to translated_attribute(scope.name), scope_scopes_path(scope)
          end
        end
      end

      # Public: A formatted collection of scopes for a given organization to be used
      # in forms.
      #
      # organization - Organization object
      #
      # Returns an Array.
      def organization_scope_types(organization = current_organization)
        [Option.new("", "-")] +
          organization.scope_types.map do |scope_type|
            Option.new(scope_type.id, translated_attribute(scope_type.name))
          end
      end

      # Public: Check if the given scopable object has the scope enabled or not.
      #
      # scopable - A scopable object.
      #
      # Returns a Boolean.
      def scopes_enabled?(scopable)
        scopable.scopes_enabled?
      end
    end
  end
end
