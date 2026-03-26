# frozen_string_literal: true

module Decidim
  module Log
    module ValueTypes
      # This class presents the given value as an access mode. Check
      # the `DefaultPresenter` for more info on how value
      # presenters work.
      class AccessModePresenter < DefaultPresenter
        # Public: Presents the value as an access mode. If the access mode can
        # be found, it shows its translated label. Otherwise it shows a fallback message.
        #
        # Returns an HTML-safe String.
        def present
          return unless value
          return translated_access_mode if valid_access_mode?

          I18n.t("not_found", id: value, scope: "decidim.log.value_types.access_mode_presenter")
        end

        private

        def valid_access_mode?
          access_modes.has_value?(value.to_i)
        end

        def translated_access_mode
          I18n.t(access_mode_key, scope: "decidim.log.value_types.access_mode_presenter.access_modes")
        end

        def access_mode_key
          access_modes.key(value.to_i)
        end

        def access_modes
          # Access modes are consistent across participatory spaces (assemblies, processes, etc.)
          # open: 0 - fully visible and accessible
          # transparent: 1 - visible but content restricted
          # restricted: 2 - not visible, requires permission
          { open: 0, transparent: 1, restricted: 2 }
        end
      end
    end
  end
end
