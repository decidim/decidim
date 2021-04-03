# frozen_string_literal: true

module Decidim
  module AttributeObject
    autoload :Form, "decidim/attribute_object/form"
    autoload :Model, "decidim/attribute_object/model"
    autoload :NestedAttributes, "decidim/attribute_object/nested_attributes"
    autoload :NestedValidator, "decidim/attribute_object/nested_validator"
    autoload :TypeMap, "decidim/attribute_object/type_map"

    def self.model
      # This provides the super method for the form attributes to provide
      # backwards compatibility with virtus.
      Module.new do
        extend ActiveSupport::Concern

        include Decidim::AttributeObject::Model
      end
    end
  end
end
