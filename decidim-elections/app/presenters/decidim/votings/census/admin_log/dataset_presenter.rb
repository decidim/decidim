# frozen_string_literal: true

module Decidim
  module Votings
    module Census
      module AdminLog
        # This class holds the logic to present a `Decidim::Votings::Census::Dataset`
        # for the `AdminLog` log.
        #
        # Usage should be automatic and you shouldn't need to call this class
        # directly, but here's an example:
        #
        #    action_log = Decidim::ActionLog.last
        #    view_helpers # => this comes from the views
        #    DatasetPresenter.new(action_log, view_helpers).present
        class DatasetPresenter < Decidim::Log::BasePresenter
          private

          def i18n_params
            {
              user_name: user_presenter.present,
              resource_name: Dataset.model_name.human,
              space_name: space_presenter.present
            }
          end
        end
      end
    end
  end
end
