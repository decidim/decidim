# frozen_string_literal: true

module Decidim
  #
  # This class handles all logic regarding registering menus
  #
  class Menu
    class << self
      #
      # Finds a menu by name or creates it if it doesn't exist. Optionally,
      # registers a MenuItem DSL block for the menu.
      #
      # @param name [Symbol] Name of the menu
      #
      # @yield [Menu] Invokes the block to register menu items on the menu
      #
      def register(name)
        menu = find(name) || create(name)

        yield(menu) if block_given?

        menu
      end

      #
      # Finds a menu by name
      #
      # @param name [Symbol] The name of the menu
      #
      def find(name)
        all[name]
      end

      #
      # Creates an empty named menu
      #
      # @param name [Symbol] The name of the menu
      #
      def create(name)
        all[name] = new
      end

      #
      # Destroys a named menu
      #
      # @param name [Symbol] The name of the menu
      #
      def destroy(name)
        all[name] = nil
      end

      private

      def all
        @all ||= {}
      end
    end

    def initialize
      @items = []
    end

    # Public: Registers a new item for the menu
    #
    # @param label [String, Symbol, Proc] A compulsory label for the menu item
    # @param url [String, Symbol, Proc] The URL this item will link to
    # @param options [Hash] The options for the menu item
    #
    # @option options [Float] :position
    #         The lower the position, the earlier in the menu the item will
    #         be displayed.  Default: Float::INFINITY
    #
    # @example
    #
    #   menu.item "My Resource", "/resources"
    #   menu.item "Meetings", -> { decidim_meetings.root_path }
    #   menu.item ->{ I18n.t("menu.processes") }, -> { decidim.processes_path }
    #   menu.item "Gestor de Procesos", "/processes", active: :exact
    #
    def item(label, url, options = {})
      @items << MenuItem.new(label, url, options)
    end

    #
    # The weighted list of items in the menu
    #
    def items
      @items.sort_by(&:position)
    end
  end
end
