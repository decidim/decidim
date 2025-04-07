# frozen_string_literal: true

module Decidim
  module Verifications
    module AdminLog
      class CsvDatumPresenter < Decidim::Log::BasePresenter
        def initialize(action_log, view_helpers)
          super
          @resource = action_log.resource
        end

        private

        def action_string
          case action
          when "delete", "create", "update", "import"
            "decidim.verifications.admin_log.csv_datum.#{action}"
          else
            super
          end
        end

        def i18n_params
          super.merge(
            resource_email: @resource&.email.to_s
          )
        end
      end
    end
  end
end
