# frozen_string_literal: true

module Decidim
  module Proposals
    module AdminLog
      # This class holds the logic to present a `Decidim::Proposals::Proposal`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    ProposalPresenter.new(action_log, view_helpers).present
      class ProposalPresenter < Decidim::Log::BasePresenter
        private

        def diff_fields_mapping
          {
            state: "Decidim::Proposals::AdminLog::ValueTypes::ProposalStatePresenter",
            answered_at: :date,
            answer: :i18n
          }
        end

        def action_string
          case action
          when "answer"
            "decidim.proposals.admin_log.proposal.#{action}"
          else
            super
          end
        end

        def i18n_labels_scope
          "activemodel.attributes.proposal"
        end

        def has_diff?
          action == "answer" || super
        end
      end
    end
  end
end
