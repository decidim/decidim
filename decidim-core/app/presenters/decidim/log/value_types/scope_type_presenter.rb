# frozen_string_literal: true

module Decidim
  module Log
    module ValueTypes
      # This class presents the given value as a Decidim::ScopeType. Check
      # the `DefaultPresenter` for more info on how value
      # presenters work.
      class ScopeTypePresenter < DefaultPresenter
        # Public: Presents the value as a Percentage. If the scope can
        # be found, it shows its title. Otherwise it shows its ID.
        #
        # Returns an HTML-safe String.
        def present
          return unless value
          return h.translated_attribute(scope_type.name) if scope_type

          I18n.t("not_found", id: value, scope: "decidim.log.value_types.scope_type_presenter")
        end

        private

        def scope_type
          @scope_type ||= Decidim::ScopeType.find_by(id: value)
        end
      end
    end
  end
end
