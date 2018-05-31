# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Proposals
    # This cell renders the tags for a proposal.
    class ProposalTagsCell < Decidim::ViewModel
      include ProposalCellsHelper

      property :category
      property :previous_category
      property :scope

      def show
        return unless has_category_or_scopes?
        render
      end

      private

      def category
        nil
      end

      def show_previous_category?
        options[:show_previous_category].to_s != "false"
      end

      def has_category_or_scopes?
        category.present? || has_visible_scopes?(model)
      end
    end
  end
end
