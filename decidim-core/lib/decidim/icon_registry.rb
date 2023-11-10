# frozen_string_literal: true

module Decidim
  class IconRegistry
    def initialize
      @icons = {}
    end

    def register(icon: , resource: , description: , category: )
      @icons[icon] = OpenStruct.new(icon:, resource: resource, description: description, category: category)
    end

    def find(icon)
      @icons[icon] || raise("Icon #{icon} not found")
    end
  end
end
