# frozen_string_literal: true

module Decidim
  class IconRegistry
    def initialize
      @icons = {}
    end

    def register(name:, icon:, resource:, description:, category:)
      @icons[name] = OpenStruct.new(name:, icon:, resource:, description:, category:)
    end

    def find(name)
      @icons[name] || raise("Icon #{name} not found")
    end
  end
end
