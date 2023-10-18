# frozen_string_literal: true

module Decidim
  # This cell is used a base for all List cards. It holds the basic layout
  # so other cells only have to customize a few methods or overwrite views.
  class CardLCell < Decidim::ViewModel
    include Cell::ViewModel::Partial
    include Decidim::ApplicationHelper
    include Decidim::TooltipHelper
    include Decidim::SanitizeHelper
    include Decidim::CardHelper
    include Decidim::LayoutHelper
    include Decidim::SearchesHelper

    alias resource model

    def show
      render
    end

    private

    def resource_id
      "#{class_base_name}_#{resource.id}"
    end

    def item_list_class
      return "card__list" if extra_class.blank?

      "card__list #{extra_class}"
    end

    def extra_class
      ""
    end

    def wrapper_class
      options[:wrapper_class] || ""
    end

    def html_options
      @html_options ||= options[:html_options] || {}
    end

    def presented_resource
      present(resource)
    end

    def render_extra_data?
      options[:render_extra_data]
    end

    def resource_path
      resource_locator(resource).path(url_extra_params)
    end

    def url_extra_params
      options[:url_extra_params] || {}
    end

    def class_base_name
      @class_base_name ||= resource.class.name.gsub(/\ADecidim::/, "").underscore.split("/").join("__")
    end

    def prefix_class(class_name = nil)
      return class_base_name if class_name.blank?

      "#{class_base_name}__#{class_name}"
    end

    def resource_image_path
      nil
    end

    def has_image?
      resource_image_path.present?
    end

    def has_link_to_resource?
      true
    end

    def link_whole_card?
      return true unless options.has_key?(:link_whole_card)

      options[:link_whole_card]
    end

    def has_description?
      false
    end

    def metadata_cell
      "decidim/card_metadata"
    end

    def has_author?
      false
    end

    def details_template
      return :metadata if metadata_cell.present?
      return :author if has_author?
    end

    def title
      decidim_html_escape(translated_attribute(resource.title))
    end

    def title_tag
      options[:title_tag] || :div
    end

    def description_length
      100
    end

    def description
      attribute = resource.try(:short_description) || resource.try(:body) || resource.description
      text = translated_attribute(attribute)

      decidim_sanitize_editor(html_truncate(text, length: description_length), strip_tags: true)
    end

    def has_authors?
      resource.is_a?(Decidim::Authorable) || resource.is_a?(Decidim::Coauthorable)
    end

    def render_space?
      context[:show_space].presence && resource.respond_to?(:participatory_space) && resource.participatory_space.present?
    end

    def participatory_space
      return unless render_space?

      @participatory_space ||= resource.participatory_space
    end
  end
end
