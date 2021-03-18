# frozen_string_literal: true

module Decidim
  module Votings
    module Census
      module AdminLog
        # This class holds the logic to present a `Decidim::Votings::Voting`
        # for the `AdminLog` log.
        #
        # Usage should be automatic and you shouldn't need to call this class
        # directly, but here's an example:
        #
        #    action_log = Decidim::ActionLog.last
        #    view_helpers # => this comes from the views
        #    ElectionPresenter.new(action_log, view_helpers).present
        class DatumPresenter < Decidim::Log::BasePresenter
          def i18n_params
            {
              user_name: user_presenter.present,
              resource_name: Datum.model_name.human

            }
          end
        end
      end
    end
  end
end
