# frozen_string_literal: true

module Decidim
  module Accountability
    module AdminLog
      module ValueTypes
        # This class presents the given value as a Decidim::Accountability::Result. Check
        # the `DefaultPresenter` for more info on how value presenters work.
        class ParentPresenter < Decidim::Log::ValueTypes::DefaultPresenter
          # Public: Presents the value as a Decidim::Accountability::Result. If the result can
          # be found, it shows its title. Otherwise it shows its ID.
          #
          # Returns an HTML-safe String.
          def present
            return unless value
            return h.translated_attribute(result.title) if result

            I18n.t("not_found", id: value, scope: "decidim.accountability.admin_log.value_types.parent_presenter")
          end

          private

          def result
            @result ||= Decidim::Accountability::Result.find_by(id: value)
          end
        end
      end
    end
  end
end
