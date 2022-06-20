# frozen_string_literal: true

module Decidim
  module Attributes
    # Custom attributes value to make conversion from signed id (String) to ActiveStorage::Blob easier.
    class Blob < ActiveModel::Type::Value
      def type
        :"decidim/attributes/blob"
      end

      private

      def cast_value(value)
        return value unless value.is_a?(String)

        ActiveStorage::Blob.find_signed(value)
      end
    end
  end
end
