# frozen_string_literal: true

module Decidim
  module Admin
    # This module includes helpers to show scopes in admin
    module ResourceScopeHelper
      # Public: This helper shows the th with the scope label.
      #
      # scope_label - I18n translation to show
      #
      def th_resource_scope_label(scope_label = t("decidim.admin.resources.index.headers.scope"))
        return unless resource_with_scopes_enabled?

        content_tag(:th, scope_label)
      end

      # Public: This helper shows the td for the given scope.
      #
      # current_scope - Scope object to show
      #
      def td_resource_scope_for(current_scope)
        return unless resource_with_scopes_enabled?

        scope_name = if current_scope
                       translated_attribute(current_scope.name)
                     else
                       t("decidim.scopes.global")
                     end
        content_tag(:td, scope_name)
      end

      private

      def resource_with_scopes_enabled?
        if defined? current_component
          current_component.scopes_enabled? || current_participatory_space.scopes_enabled?
        else
          current_participatory_space.scopes_enabled?
        end
      end
    end
  end
end
