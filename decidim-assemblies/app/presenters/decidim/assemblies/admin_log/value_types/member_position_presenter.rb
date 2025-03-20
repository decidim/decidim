# frozen_string_literal: true

module Decidim
  module Assemblies
    module AdminLog
      module ValueTypes
        # This class presents the given value as an assembly member position.
        # Check the `DefaultPresenter` for more info on how value presenters work.
        class MemberPositionPresenter < Decidim::Log::ValueTypes::DefaultPresenter
          # Public: Presents the value as an assembly member position.
          #
          # Returns an HTML-safe String.
          def present
            return if value.blank?

            h.t(value, scope: "decidim.admin.models.assembly_member.positions", default: value)
          end
        end
      end
    end
  end
end
