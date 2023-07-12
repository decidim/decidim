# frozen_string_literal: true

module Decidim
  # A presenter to render menus
  class MenuPresenter
    #
    # Initializes a menu for presentation
    #
    # @param name [Symbol] The name of the menu registry to be rendered
    # @param view [ActionView::Base] The view scope to render the menu
    # @param options [Hash] The rendering options for the menu entries
    #
    def initialize(name, view, options = {})
      @name = name
      @view = view
      @options = options
    end

    delegate :items, to: :evaluated_menu
    delegate :content_tag, :safe_join, to: :@view

    def evaluated_menu
      @evaluated_menu ||= begin
        menu = Menu.new(@name)
        menu.build_for(@view)
        menu
      end
    end

    def active_item
      presented_items.find(&:active?)
    end

    def render
      content_tag :nav, class: "main-nav", "aria-label": @options.fetch(:label, nil) do
        render_menu
      end
    end

    protected

    def render_menu(&block)
      content_tag :ul, @options.fetch(:container_options, {}) do
        elements = block_given? ? [block.call(@view)] : []
        safe_join(elements + menu_items)
      end
    end

    def presented_items
      @presented_items ||= items.map do |menu_item|
        MenuItemPresenter.new(menu_item, @view, @options)
      end
    end

    def menu_items
      presented_items.map(&:render)
    end
  end
end
