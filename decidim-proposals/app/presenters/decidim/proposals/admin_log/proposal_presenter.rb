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

        def resource_presenter
          @resource_presenter ||= Decidim::Proposals::Log::ResourcePresenter.new(action_log.resource, h, action_log.extra["resource"])
        end

        def diff_fields_mapping
          {
            title: "Decidim::Proposals::AdminLog::ValueTypes::ProposalTitleBodyPresenter",
            body: "Decidim::Proposals::AdminLog::ValueTypes::ProposalTitleBodyPresenter",
            state: "Decidim::Proposals::AdminLog::ValueTypes::ProposalStatePresenter",
            answered_at: :date,
            answer: :i18n
          }
        end

        def action_string
          case action
          when "answer", "create", "update", "proposal_linked_with_result"
            "decidim.proposals.admin_log.proposal.#{action}"
          else
            super
          end
        end

        def i18n_labels_scope
          "activemodel.attributes.proposal"
        end

        def i18n_params
          super.merge(result_name: result_presenter.present)
        end

        def has_diff?
          action == "answer" || super
        end

        def result
          @result ||= GlobalID::Locator.locate action_log.extra["result"]
        end

        def result_presenter
          Decidim::Log::ResourcePresenter.new(result, h, "title" => action_log.extra["result_title"])
        end
      end
    end
  end
end
