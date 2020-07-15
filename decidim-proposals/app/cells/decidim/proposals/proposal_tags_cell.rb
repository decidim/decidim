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
      property :previous_scope

      def show
        render if has_category_or_scopes?
      end

      private

      def show_previous_category?
        options[:show_previous_category].to_s != "false"
      end

      def show_previous_scope?
        options[:show_previous_scope].to_s != "false"
      end

      def has_category_or_scopes?
        category.present? || has_visible_scopes?(model)
      end
    end
  end
end
