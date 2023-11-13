# frozen_string_literal: true

module Decidim
  class IconRegistry
    def initialize
      @icons = ActiveSupport::HashWithIndifferentAccess.new
    end

    # Registers a new icon.
    #
    # @param name [String] The name of the icon. It will be used to find the icon later.
    # @param icon [String] The id of the icon. It will be used to load the icon from remixicon library.
    # @param resource [String] The resource name. The resource name. It will be used to link the icon to a specific resource.
    # @param category [String] The category name. It will be used to group the icons by category.
    # @param description [String] The description of the icon. It will be used to show the purpose of the icon in DDG.
    # @param engine [String] The engine name.It is used internally to identify the module where the icon is being used.
    def register(name:, icon:, resource:, description:, category:, engine:) # rubocop:disable Metrics/ParameterLists
      ActiveSupport::Deprecation.warn("#{name} already registered. #{@icons[name].inspect}") if @icons[name]

      @icons[name] = { name:, icon:, resource:, description:, category:, engine: }
    end

    def find(name)
      raise "Icon name cannot be blank" if name.blank?

      @icons[name] || deprecated(name)
    end

    def all
      @icons
    end

    def categories(field = :category)
      all.values.group_by { |d| d[field].try(:to_s) }
    end

    private

    def deprecated(name)
      message = %{Icon #{name} not found. Register it with \n
        Decidim.icons.register(name: "#{name}", icon: "#{name}", resource: "core", category: "system", description: "")
      }

      raise message || ActiveSupport::Deprecation.warn(message)
    end
  end
end
