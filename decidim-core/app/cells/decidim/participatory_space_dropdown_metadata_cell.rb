# frozen_string_literal: true

module Decidim
  class ParticipatorySpaceDropdownMetadataCell < Decidim::ViewModel
    include Decidim::TwitterSearchHelper
    include Decidim::SanitizeHelper

    private

    def nav_items_method = nil

    def nav_items
      return [] if nav_items_method.blank?
      return [] if (nav_items = try(nav_items_method, model)).blank?

      nav_items
    end

    def title
      decidim_html_escape(translated_attribute(model.try(:title) || model.try(:name) || ""))
    end

    def hashtag
      return unless model.respond_to?(:hashtag)

      @hashtag ||= decidim_html_escape(model.hashtag) if model.hashtag.present?
    end

    def id
      return "#{model.id}-mobile" if options[:mobile]

      model.id
    end
  end
end
