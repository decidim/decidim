# frozen_string_literal: true

module Decidim
  module Proposals
    class ProposalSuggestionCardCell < Decidim::ViewModel
      include Cell::ViewModel::Partial
      include Decidim::TooltipHelper
      include Decidim::CardHelper
      include Decidim::LayoutHelper
      include ApplicationHelper

      alias resource model

      def show
        render :proposal_card
      end

      def resource_id
        "#{class_base_name}_#{resource.id}"
      end

      def item_list_class
        "card__list"
      end

      def html_options
        @html_options ||= options[:html_options] || {}
      end

      def class_base_name
        @class_base_name ||= resource.class.name.gsub(/\ADecidim::/, "").underscore.split("/").join("__")
      end

      def wrapper_class
        options[:wrapper_class] || ""
      end

      def resource_path
        resource_locator(resource).path(url_extra_params)
      end

      def show_space?
        (context[:show_space].presence || options[:show_space].presence) && resource.respond_to?(:participatory_space) && resource.participatory_space.present?
      end

      def title
        decidim_escape_translated(resource.title)
      end

      def title_tag
        options[:title_tag] || :div
      end

      def url_extra_params
        options[:url_extra_params] || {}
      end

      def comments_count_item(commentable = resource)
        return unless commentable.is_a?(Decidim::Comments::Commentable) && commentable.commentable?

        {
          text: commentable.comments_count,
          icon: resource_type_icon_key(:comments_count),
          data_attributes: { comments_count: "" }
        }
      end

      def endorsements_count_item
        return unless resource.respond_to?(:endorsements_count)

        {
          text: resource.endorsements_count,
          icon: resource_type_icon_key(:like),
          data_attributes: { endorsements_count: "" }
        }
      end

      def proposal_items
        items ||= []
        items << comments_count_item
        items << endorsements_count_item
      end
    end
  end
end
