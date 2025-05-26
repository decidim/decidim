# frozen_string_literal: true

module Decidim
  module Proposals
    # This cell renders metadata for an instance of a Proposal
    class ProposalMetadataCell < Decidim::CardMetadataCell
      include Decidim::Proposals::ApplicationHelper

      delegate :state, to: :model

      def initialize(*)
        super

        @items.prepend(*proposal_items)
      end

      def state_item
        return if state.blank? || @options.fetch(:skip_state, false)

        if model.withdrawn?
          { text: content_tag(:span, humanize_proposal_state(:withdrawn), class: "label alert") }
        elsif model.emendation?
          { text: content_tag(:span, humanize_proposal_state(state), class: "label #{state_class}") }
        else
          { text: content_tag(:span, translated_attribute(model.proposal_state&.title), class: "label", style: model.proposal_state.css_style) }
        end
      end

      def state_class
        return "alert" if model.withdrawn?

        case state
        when "accepted"
          "success"
        when "rejected"
          "alert"
        when "evaluating"
          "warning"
        else
          "muted"
        end
      end

      private

      def proposal_items
        [coauthors_item] + taxonomy_items + [comments_count_item, likes_count_item, state_item, emendation_item]
      end

      def items_for_map
        [coauthors_item_for_map, comments_count_item, likes_count_item, state_item, emendation_item].compact_blank.map do |item|
          {
            text: item[:text].to_s.html_safe,
            icon: item[:icon].present? ? icon(item[:icon]).html_safe : nil
          }
        end
      end

      def coauthors_item_for_map
        presented_author = official? ? Decidim::Proposals::OfficialAuthorPresenter.new : present(resource.identities.first)

        {
          text: presented_author.name,
          icon: "account-circle-line"
        }
      end
    end
  end
end
