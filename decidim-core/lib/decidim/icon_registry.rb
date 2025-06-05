# frozen_string_literal: true

module Decidim
  class IconRegistry
    def initialize
      @icons = ActiveSupport::HashWithIndifferentAccess.new
    end

    # It allows detecting with icons are valid remixicons icons, and also for documenting them in the
    # `decidim-design` (aka Decidim Design Guide or DDG).
    #
    # Some of these fields are used to load and work with the icon (`name` and `icon`) and others are
    # for documentation purposes in DDG (`category`, `description`, and `engine`).
    #
    # @param name [String] The name of the icon. It will be used to find the icon later.
    # @param icon [String] The id of the icon. It will be used to load the icon from remixicon library.
    # @param category [String] The category name. It will be used to group the icons by category.
    # @param description [String] The description of the icon. It will be used to show the purpose of the icon in DDG.
    # @param engine [String] The engine name. It is used internally to identify the module where the icon is being used.
    def register(name:, icon:, description:, category:, engine:)
      Decidim.deprecator.warn("#{name} already registered. #{@icons[name].inspect}") if @icons[name]

      @icons[name] = { name:, icon:, description:, category:, engine: }
    end

    def find(name)
      if name.blank?
        Decidim.deprecator.warn "The requested icon is blank."
        name = "other"
      end

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
        Decidim.icons.register(name: "#{name}", icon: "#{name}", category: "system", description: "", engine: :core)
      }

      Decidim.deprecator.warn(message)
      raise message if Rails.env.local?

      @icons["other"]
    end
  end
end
