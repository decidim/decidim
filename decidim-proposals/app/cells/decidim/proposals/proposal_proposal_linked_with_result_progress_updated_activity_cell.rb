# frozen_string_literal: true

module Decidim
  module Proposals
    # A cell to display when a result linked with a proposal has updated its
    # progress.
    class ProposalProposalLinkedWithResultProgressUpdatedActivityCell < ProposalActivityCell
      include ActiveSupport::NumberHelper

      def title
        I18n.t(
          "decidim.proposals.last_activity.proposal_linked_with_result_progress_updated.title",
          proposal_link: proposal_link
        )
      end

      def result
        @result ||= GlobalID::Locator.locate model.extra["result"]
      end

      def proposal_path
        resource_locator(resource).path
      end

      def proposal_name
        translated_attribute(model.extra["proposal_title"])
      end

      def proposal_link
        return proposal_name unless resource
        link_to proposal_name, proposal_path
      end

      def result_path
        resource_locator(result).path
      end

      def result_name
        translated_attribute(model.extra["result_title"])
      end

      def result_link
        return result_name unless result
        link_to result_name, result_path
      end

      def resource_link_path
        result_path
      end

      def resource_link_text
        result_name
      end

      def description
        progress = number_to_percentage model.extra["result_progress"], precision: 2
        I18n.t(
          "decidim.proposals.last_activity.proposal_linked_with_result_progress_updated.description",
          progress: progress
        )
      end

      def proposal_title
        resource_title
      end

      def show_author?
        false
      end
    end
  end
end
