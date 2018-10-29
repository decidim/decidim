# frozen_string_literal: true

module Decidim
  module Conferences
    module AdminLog
      module ValueTypes
        # This class presents the given value as a user role. Check
        # the `DefaultPresenter` for more info on how value
        # presenters work.
        class RolePresenter < Decidim::Log::ValueTypes::DefaultPresenter
          # Public: Presents the value as a user role.
          #
          # Returns an HTML-safe String.
          def present
            return if value.blank?

            h.t(value, scope: "decidim.admin.models.conference_user_role.roles", default: value)
          end
        end
      end
    end
  end
end
