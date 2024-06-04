# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Proposals
    # This cell renders the proposal card for an instance of a Proposal
    # the default size is the Grid Card (:g)
    class ProposalGCell < Decidim::CardGCell
      include Decidim::Proposals::ApplicationHelper
      include Decidim::LayoutHelper

      delegate :state_class, to: :metadata_cell_instance

      def show
        render
      end

      def title
        present(model).title(html_escape: true)
      end

      def metadata_cell
        "decidim/proposals/proposal_metadata"
      end

      def metadata_cell_instance
        @metadata_cell_instance ||= cell("decidim/proposals/proposal_metadata", model)
      end

      def resource_image_path
        model.attachments.first&.url
      end

      def proposal_state_item
        return if model.state.blank?

        @proposal_state_item ||= { text: content_tag(:span, humanize_proposal_state(model.state), class: "label #{state_class}") }
      end

      private

      def classes
        super.merge(metadata: "card__list-metadata")
      end
    end
  end
end
