# frozen_string_literal: true

module Decidim
  module Proposals
    # A cell to display when a proposal has been linked with a result.
    class ProposalProposalLinkedWithResultActivityCell < ProposalActivityCell
      def title
        I18n.t(
          "decidim.proposals.last_activity.proposal_linked_with_result",
          result_link: result_link
        )
      end

      def result
        @result ||= GlobalID::Locator.locate model.extra["result"]
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

      def show_author?
        false
      end
    end
  end
end
