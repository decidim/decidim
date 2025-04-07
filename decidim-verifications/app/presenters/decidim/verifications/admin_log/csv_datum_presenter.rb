# frozen_string_literal: true

module Decidim
  module Verifications
    module AdminLog
      # This class holds the logic to present a `Decidim::Verifications::::CsvDatum
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you should not need to call this class
      # directly, but here is an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    VerificationPresenter.new(action_log, view_helpers).present
      class CsvDatumPresenter < Decidim::Log::BasePresenter
        private

        def action_string
          case action
          when "delete", "create", "update", "import"
            "decidim.verifications.admin_log.csv_datum.#{action}"
          else
            super
          end
        end
      end
    end
  end
end
