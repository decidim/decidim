# frozen_string_literal: true

module Decidim
  # This module provides functionality to create objects with attributes that
  # are not attached to any database objects and have type coercions for the
  # types of their objects. This is a similar concept as Virtus used to provide
  # for the core objects, such as Forms and manifest classes. The programming
  # API is backwards compatible with Virtus on most parts.
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
