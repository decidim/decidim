# frozen_string_literal: true

module Decidim
  module Attributes
    # Custom attributes value to make conversion from signed id to ActiveStorage::Blob easier.
    # Signed id is a string that we pass as a param so that we can locate the uploaded file.
    # and blob is an instance of ActiveStorage::Blob which contains the metadata about
    # a file and a key for where that file resides on the service.
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
