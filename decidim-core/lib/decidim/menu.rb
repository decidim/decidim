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
      # @param &block [Menu] Registration body of the menu. It's stored to be
      #                      evaluated at rendering time
      #
      def register(name, &block)
        menu = find(name) || create(name)

        menu.configurations << block

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

    attr_reader :configurations

    def initialize
      @configurations = []
    end

    #
    # Evaluates the registered configurations for this menu in a view context
    #
    def build_for(context)
      @items = []

      @configurations.each do |configuration|
        context.instance_exec(self, &configuration)
      end
    end

    # Public: Registers a new item for the menu
    #
    # @param label [String, Symbol] A compulsory label for the menu item
    # @param url [String, Symbol] The URL this item will link to
    # @param options [Hash] The options for the menu item
    #
    # @option options [Float] :position
    #         The lower the position, the earlier in the menu the item will
    #         be displayed.  Default: Float::INFINITY
    #
    # @option options [Symbol, Proc] :if
    #         Decides whether the menu item will be displayed. Evaluated on
    #         each request.
    #
    # @example
    #
    #   menu.item "My Resource", "/resources"
    #   menu.item I18n.t("menu.meetings"), decidim_meetings.root_path
    #   menu.item current_user.username, decidim.profile_path
    #   menu.item "Gestor de Procesos", "/processes", active: :exact
    #   menu.item "Gestor de Procesos", "/processes", if: admin?
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
