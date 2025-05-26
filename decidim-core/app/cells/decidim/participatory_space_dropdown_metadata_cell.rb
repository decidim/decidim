# frozen_string_literal: true

module Decidim
  class ParticipatorySpaceDropdownMetadataCell < Decidim::ViewModel
    include Decidim::TwitterSearchHelper

    private

    def nav_items_method = nil

    def nav_items
      return [] if nav_items_method.blank?
      return [] if (nav_items = try(nav_items_method, model)).blank?

      nav_items
    end

    def title
      decidim_escape_translated(model.try(:title) || model.try(:name) || "")
    end

    def id
      return "#{model.id}-mobile" if options[:mobile]

      model.id
    end
  end
end
