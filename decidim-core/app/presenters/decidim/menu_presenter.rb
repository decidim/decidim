# frozen_string_literal: true

module Decidim
  # A presenter to render menus
  class MenuPresenter
    #
    # Initializes a menu for presentation
    #
    # @param name [Symbol] The name of the menu registry to be rendered
    # @param view [ActionView::Base] The view scope to render the menu
    #
    def initialize(name, view)
      @name = name
      @view = view
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

    def as_nav_list
      content_tag :ul, class: "main-nav" do
        safe_join(menu_items)
      end
    end

    private

    def menu_items
      items.map do |menu_item|
        content_tag :li do
          MenuItemPresenter.new(menu_item, @view).as_link
        end
      end
    end
  end
end
