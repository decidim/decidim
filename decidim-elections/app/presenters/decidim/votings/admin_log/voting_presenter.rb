# frozen_string_literal: true

module Decidim
  module Votings
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
      class VotingPresenter < Decidim::Log::BasePresenter
        private

        def diff_fields_mapping
          {
            title: :i18n,
            description: :i18n,
            slug: :string,
            start_time: :date,
            end_time: :date,
            decidim_scope_id: :scope,
            published_at: :date
          }
        end

        def i18n_labels_scope
          "activemodel.attributes.voting"
        end

        def action_string
          case action
          when "create", "publish", "unpublish"
            "decidim.votings.admin_log.voting.#{action}"
          else
            super
          end
        end
      end
    end
  end
end
