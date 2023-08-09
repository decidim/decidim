# frozen_string_literal: true

module Decidim
  # This cell is used a base for all Grid cards. It holds the basic layout
  # so other cells only have to customize a few methods or overwrite views.
  class CardGCell < Decidim::ViewModel
    # avoid metaprogramming in CSS classes due to Tailwind purge
    DEFAULT_CSS = {
      default: "card__grid",
      img: "card__grid-img",
      text: "card__grid-text",
      metadata: "card__grid-metadata"
    }.freeze

    HIGHLIGHT_CSS = {
      default: "card__highlight",
      img: "card__highlight-img",
      text: "card__highlight-text",
      metadata: "card__highlight-metadata"
    }.freeze

    include Decidim::ApplicationHelper
    include Decidim::SanitizeHelper

    alias resource model

    def show
      render
    end

    private

    def highlight?
      options[:highlight] == true
    end

    def classes
      @classes ||= highlight? ? HIGHLIGHT_CSS : DEFAULT_CSS
    end

    def resource_id
      return "#{id_base_name}#{"_highlight" if highlight?}_#{resource.id}" unless options.has_key?(:id)

      options[:id]
    end

    def resource_path
      resource_locator(resource).path
    end

    def id_base_name
      @id_base_name ||= resource.class.name.gsub(/\ADecidim::/, "").underscore.split("/").join("__")
    end

    def resource_image_path
      nil
    end

    def has_image?
      resource_image_path.present?
    end

    def show_description?
      highlight?
    end

    def metadata_cell
      nil
    end

    def has_author?
      false
    end

    def title
      decidim_html_escape(translated_attribute(resource.title))
    end

    def alt_title
      [t("decidim.application.photo.alt"), decidim_html_escape(translated_attribute(resource.title))].join(": ")
    end

    def title_tag
      options[:title_tag] || :h3
    end

    def title_class
      "#{highlight? ? "h3" : "h4"} text-secondary"
    end

    def description
      attribute = resource.try(:short_description) || resource.try(:body) || resource.description
      text = translated_attribute(attribute)

      strip_tags(html_truncate(text, length: 300))
    end

    def has_authors?
      resource.is_a?(Decidim::Authorable) || resource.is_a?(Decidim::Coauthorable)
    end
  end
end
