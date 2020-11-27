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

    included do
      # Store the encrypted attributes in a class accessor
      cattr_accessor :encrypted_attributes

      before_save :ensure_encrypted_attributes if respond_to?(:before_save)
      after_save :clear_encrypted_attributes_cache if respond_to?(:after_save)
    end

    class_methods do
      # Public: Defines an attribute that should be encrypted
      def encrypt_attribute(attribute, type:)
        self.encrypted_attributes ||= []
        raise "The attribute #{attribute} is already defined as encrypted" if encrypted_attributes.include?(attribute)

        encrypted_attributes << attribute

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
            return @#{attribute}_decrypted if instance_variable_defined?(:@#{attribute}_decrypted)

            encrypted_value = begin
              if defined?(super)
                super
              elsif instance_variable_defined?(:@#{attribute})
                @#{attribute}
              end
            end
            @#{attribute}_decrypted = decrypt_#{method_suffix}(encrypted_value)
          end

          def #{attribute}=(value)
            remove_instance_variable(:@#{attribute}_decrypted) if instance_variable_defined?(:@#{attribute}_decrypted)
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

    # Re-assign the encrypted attributes before save so they are also saved when
    # they are modified without calling the accessors. This could happen e.g.
    # for hashes which are modified directly as follows:
    #
    #  record = Example.find(1)
    #  record.metadata["foo"] = "bar"
    #  record.save!
    def ensure_encrypted_attributes
      self.class.encrypted_attributes.each do |attr|
        send("#{attr}=", send(attr))
      end
    end

    # This clears the cache after the record is saved so that the values are
    # re-fetched after the save.
    def clear_encrypted_attributes_cache
      self.class.encrypted_attributes.each do |attr|
        next unless instance_variable_defined?("@#{attr}_decrypted")

        remove_instance_variable("@#{attr}_decrypted")
      end
    end

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
