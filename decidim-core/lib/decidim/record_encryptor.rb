# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # A concern that provides attribute encryption e.g. to active record models.
  #
  # Use this e.g. in models as follows:
  #
  # class Example < ApplicationRecord
  #   include Decidim::RecordEncryptor
  #
  #   encrypt_attribute :name, type: :string
  #   encrypt_attribute :metadata, type: :hash
  # end
  module RecordEncryptor
    extend ActiveSupport::Concern

    class_methods do
      # Public: Defines an attribute that should be encrypted
      def encrypt_attribute(attribute, type:)
        # Defines the suffix for the encrypt and decrypt methods. E.g. when
        # the `type` is `:hash`, method `decrypt_hash_values` would be called
        # for decryption and `encrypt_hash_values` would be called for
        # encryption.
        method_suffix = begin
          case type
          when :hash
            "hash_values"
          else
            "value"
          end
        end

        # Dynamically defines the getter and setter for the encrypted attribute.
        # E.g. when called as `encrypt_attribute :name, type: :string`, this
        # would define the following methods:
        #
        #   def name
        #     decrypt_value(super)
        #   end
        #
        #   def name=(value)
        #     super(encrypt_value(value))
        #   end
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{attribute}
            encrypted_value = begin
              if defined?(super)
                super
              elsif instance_variable_defined?(:@#{attribute})
                @#{attribute}
              else
                nil
              end
            end

            decrypt_#{method_suffix}(encrypted_value)
          end

          def #{attribute}=(value)
            encrypted_value = encrypt_#{method_suffix}(value)

            if defined?(super)
              super(encrypted_value)
            else
              @#{attribute} = encrypted_value
            end
          end
        RUBY
      end
    end

    private

    def decrypt_value(value)
      Decidim::AttributeEncryptor.decrypt(value)
    rescue ActiveSupport::MessageEncryptor::InvalidMessage
      # Support for legacy unencrypted values
      value
    end

    def encrypt_value(value)
      Decidim::AttributeEncryptor.encrypt(value)
    end

    def decrypt_hash_values(hash)
      return hash unless hash.is_a?(Hash)

      hash.transform_values { |value| decrypt_value(value) }
    end

    def encrypt_hash_values(hash)
      return hash unless hash.is_a?(Hash)

      hash.transform_values { |value| encrypt_value(value) }
    end
  end
end
