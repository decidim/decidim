# frozen_string_literal: true

module Decidim
  class ResourceHistoryCell < Decidim::ViewModel
    def show
      render
    end

    def history_items
      return @history_items if @history_items.present?

      @history_items = []
      linked_resources_items.each do |item|
        add_linked_resources_items(item[:resources], item)
      end

      @history_items << creation_item if @history_items.any?

      @history_items.sort_by! { |item| item[:date] }
    end

    # return an unique id to identify the type of history cell
    def history_cell_id
      raise NotImplementedError
    end

    # return an array of linked resources to show in the history
    def linked_resources_items
      raise NotImplementedError
    end

    # return the creation item to show in the history, it will be added only if there are linked resources
    def creation_item
      raise NotImplementedError
    end

    def render?
      linked_resources_items.any? { |item| item[:resources].present? }
    end

    private

    def add_linked_resources_items(resources, options)
      return if resources.blank?

      resources.each do |resource|
        title = decidim_sanitize_translated(resource.title)
        url = resource_locator(resource).path
        link = link_to(title, url, class: "underline decoration-current text-secondary font-semibold")

        @history_items << {
          id: "#{options[:link_name]}_#{resource.id}",
          date: resource.published_at,
          text: t(options[:text_key], scope: "activerecord.models", link:),
          icon: resource_type_icon_key(options[:icon_key])
        }
      end
    end

    def history_items_contains?(link_name)
      return false if @history_items.blank?

      @history_items.any? { |item| item[:id].include?(link_name.to_s) }
    end
  end
end
