module Decidim
  class FeatureConfiguration
    attr_reader :attributes

    def initialize
      @attributes = {}
    end

    def attribute(name, options = {})
      @attributes[name.to_sym] = Attribute.new(options)
    end
  end

  class Attribute
    include Virtus.model

    attribute :type, Symbol, default: :boolean
  end
end
