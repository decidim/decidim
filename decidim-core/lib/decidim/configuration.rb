module Decidim
  class Configuration
    attr_reader :attributes

    def initialize
      @attributes = {}
    end

    def attribute(name, type, options = {})
      @attributes[name.to_sym] = { type: type, options: options }
    end
  end
end
