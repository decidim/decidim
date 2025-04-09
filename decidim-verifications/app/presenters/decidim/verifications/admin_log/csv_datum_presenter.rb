# frozen_string_literal: true

module Decidim
  module Verifications
    module AdminLog
      # This class holds the logic to present a `Decidim::Verifications::CsvDatum
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you should not need to call this class
      # directly, but here is an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    CsvDatumPresenter.new(action_log, view_helpers).present
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
            resource_email: @resource&.email.to_s,
            imported_count: imported_records.count
          )
        end

        def imported_records
          action_log.extra.dig("extra", "imported_records") || []
        end
      end
    end
  end
end
