# frozen_string_literal: true

module Decidim
  #
  # This class handles all logic regarding registering menus
  #
  class Menu
    def initialize(name)
      @name = name
      @items = []
      @removed_items = []
      @ordered_elements = []
    end

    #
    # Evaluates the registered configurations for this menu in a view context
    #
    def build_for(context)
      raise "Menu #{@name} is not registered" if registry.blank?

      registry.configurations.each do |configuration|
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
    #   menu.item current_user.username, decidim.profile_path(current_user.nickname)
    #   menu.item "Gestor de Procesos", "/processes", active: :exact
    #   menu.item "Gestor de Procesos", "/processes", if: admin?
    #
    def item(label, url, options = {})
      Decidim.deprecator.warn("Using menu.item in #{@name} context is deprecated. Use menu.add_item")
      add_item(nil, label, url, options)
    end

    # Public: Registers a new item for the menu
    #
    # @param identifier [String, Symbol] A compulsory identifier for the menu item
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
    #   menu.add_item :resources, "My Resource", "/resources"
    #   menu.add_item :meetings, I18n.t("menu.meetings"), decidim_meetings.root_path
    #   menu.add_item :profile, current_user.username, decidim.profile_path(current_user.nickname)
    #   menu.add_item :processes,"Gestor de Procesos", "/processes", active: :exact
    #   menu.add_item :processes,"Gestor de Procesos", "/processes", if: admin?
    #
    def add_item(identifier, label, url, options = {})
      options = { position: (1 + @items.length) }.merge(options)
      @items << MenuItem.new(label, url, identifier, options)
    end

    def move(element, after: nil, before: nil)
      if after.present?
        @ordered_elements << { movable: element, anchor: after, operation: :+ }
      elsif before.present?
        @ordered_elements << { movable: element, anchor: before, operation: :- }
      else
        raise ArgumentError, "The Decidim::Menu.move method has been called with invalid parameters"
      end
    end

    # Public: Registers a new item for the menu
    #
    # @param identifier [String, Symbol] A compulsory label for the menu item
    #
    # @example
    #
    #   menu.remove_item :root
    def remove_item(item)
      @removed_items << item
    end

    #
    # The weighted list of items in the menu
    #
    def items
      @items.reject! { |item| @removed_items.include?(item.identifier) }
      @ordered_elements.each { |item| move_element(**item) }
      @items.select(&:visible?).sort_by(&:position)
    end

    private

    def move_element(movable:, anchor:, operation:)
      anchor = @items.select { |x| x.identifier == anchor }.first
      movable = @items.select { |x| x.identifier == movable }.first
      raise ArgumentError, "The Decidim::Menu.move has been requested to move an element that does not exist" if movable.blank?
      raise ArgumentError, "The Decidim::Menu.move has been requested to move before / after an element that does not exist" if anchor.blank?

      movable.position = anchor.position.send(operation, 0.0001) if movable.present? && anchor.present?
    end

    def registry
      @registry ||= MenuRegistry.find(@name)
    end
  end
end
