# frozen_string_literal: true

module Decidim
  module Log
    module ValueTypes
      # This class presents the given value as a Decidim::Scope. Check
      # the `DefaultPresenter` for more info on how value
      # presenters work.
      class ScopePresenter < DefaultPresenter
        # Public: Presents the value as a Percentage. If the scope can
        # be found, it shows its title. Otherwise it shows its ID.
        #
        # Returns an HTML-safe String.
        def present
          return unless value
          return h.translated_attribute(scope.name) if scope
          I18n.t("not_found", id: value, scope: "decidim.log.value_types.scope_presenter")
        end

        private

        def scope
          @scope ||= Decidim::Scope.where(id: value).first
        end
      end
    end
  end
end
