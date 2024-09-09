# frozen_string_literal: true

module Decidim
  class ResourceHistoryCell < Decidim::ViewModel
    include Decidim::Budgets::ApplicationHelper
    include Decidim::Proposals::ApplicationHelper
    include Decidim::Accountability::ApplicationHelper

    def show
      render
    end

    def history_items
      return @history_items if @history_items.present?

      @history_items = []
      add_history_items

      @history_items.sort_by! { |item| item[:date] }
    end

    private

    def add_history_items
      raise NotImplemented
    end

    def add_linked_resources_items(items, resources, link_name, text_key, icon_key)
      return if resources.blank?

      resources.each do |resource|
        title = decidim_sanitize_translated(resource.title[I18n.locale.to_s])
        url = resource_locator(resource).path
        link = link_to(title, url, class: "underline decoration-current text-secondary font-semibold")

        items << {
          id: "#{link_name}_#{resource.id}",
          date: resource.updated_at,
          text: t(text_key, scope: "activerecord.models", link:),
          icon: resource_type_icon_key(icon_key)
        }
      end
    end

    def history_items_contains?(link_name)
      return false if @history_items.blank?

      @history_items.any? { |item| item[:id].include?(link_name.to_s) }
    end
  end
end
