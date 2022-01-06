# frozen_string_literal: true

module Decidim
  module AttributeObject
    autoload :Form, "decidim/attribute_object/form"
    autoload :Model, "decidim/attribute_object/model"
    autoload :NestedValidator, "decidim/attribute_object/nested_validator"
    autoload :TypeMap, "decidim/attribute_object/type_map"
    autoload :TypeResolver, "decidim/attribute_object/type_resolver"

    def self.types
      @types ||= TypeResolver.new
    end

    def self.type(type, **options)
      typedef = types.resolve(type, **options)

      ActiveModel::Type.lookup(typedef[:type], **typedef[:options])
    end
  end
end
