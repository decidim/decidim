# frozen_string_literal: true

module Decidim
  class IconRegistry
    def initialize
      @icons = ActiveSupport::HashWithIndifferentAccess.new
    end

    def register(name:, icon:, resource:, description:, category:)
      raise "#{name} already registered" if @icons[name]

      @icons[name] = { name:, icon:, resource:, description:, category: }
    end

    def find(name)
      @icons[name] || deprecated(name)
    end

    def all
      @icons
    end

    def categories
      @icons.sort_by { |k| k["category"] }
    end

    def deprecated(name)
      message = %{Icon #{name} not found. Register it with \n
        Decidim.icons.register(name: "#{name}", icon: "#{name}", resource: "core", category: "system", description: "")
      }

      raise message || ActiveSupport::Deprecation.warn(message)
    end
  end
end
