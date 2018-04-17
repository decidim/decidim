# frozen_string_literal: true

module Rectify
  class FormatAttributesHash
    private

    def convert_indexed_hashes_to_arrays(attributes_hash)
      array_attributes.each do |array_attribute|
        name = array_attribute.name
        attribute = attributes_hash[name]
        next unless attribute.is_a?(Hash)

        attributes_hash[name] = transform_values_for_type(
          attribute.values,
          array_attribute.member_type.primitive
        )
      end
    end

    def transform_values_for_type(values, element_type)
      return values unless element_type < Rectify::Form

      values.map do |value|
        self.class.new(element_type.attribute_set).format(value)
      end
    end

    def array_attributes
      attribute_set.select { |attribute| attribute.primitive == Array }
    end
  end
end
