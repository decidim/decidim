# frozen_string_literal: true

module Decidim
  class UserActivityCell < Decidim::ViewModel
    include Cell::ViewModel::Partial
    include CellsPaginateHelper
    include Decidim::Core::Engine.routes.url_helpers
    include ActionView::Helpers::FormOptionsHelper
    include Decidim::FiltersHelper
    include Decidim::LayoutHelper
    include Decidim::IconHelper

    def show
      render :show
    end

    def activities
      context[:activities]
    end

    def resource_types
      context[:resource_types]
    end

    def resource_items
      resource_types.map do |resource_type|
        {
          name: resource_type,
          translation: I18n.t(resource_type.split("::").last.underscore, scope: "decidim.components.component_order_selector.order"),
          filter: { resource_type: resource_type }
        }
      end
    end

    def filter_items
      resource_items.prepend(
        name: all_types_key,
        translation: t("decidim.components.component_order_selector.order.all_types")
      )
    end

    def filter_items_for_radiobuttons
      filter_items.map { |e| OpenStruct.new(e.merge(text: text_for(e[:name], e[:translation]))) }
    end

    def text_for(name, translation)
      text = ""
      text += resource_type_icon name, class: "w-6 h-6 md:w-4 md:h-4 flex-none text-gray group-hover:text-secondary fill-current"
      text += content_tag :span, translation, class: "hidden md:block text-sm text-gray-2 first-letter:uppercase group-hover:text-secondary group-hover:font-semibold"
      text.html_safe
    end

    def filter
      context[:filter]
    end

    def all_types_key
      "all"
    end

    def current_resource_type
      return all_types_key unless resource_types.include? filter.resource_type

      filter.resource_type
    end
  end
end
