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
        method_suffix = case type
                        when :hash
                          "hash_values"
                        else
                          "value"
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

          # def full_name
          #   return @full_name_decrypted if instance_variable_defined?(:@full_name_decrypted)
          #
          #   encrypted_value = begin
          #     if defined?(super)
          #       super
          #     elsif instance_variable_defined?(:@full_name)
          #       @full_name
          #     end
          #   end
          #   @full_name_decrypted = decrypt_value(encrypted_value)
          # end
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

          # def full_name=(value)
          #   remove_instance_variable(:@full_name_decrypted) if instance_variable_defined?(:@full_name_decrypted)
          #   encrypted_value = encrypt_value(value)
          #
          #   if defined?(super)
          #     super(encrypted_value)
          #   else
          #     @full_name = encrypted_value
          #   end
          # end
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
    #
    # This will also clear the cached attributes during saving so that next time
    # they are accessed, they will be updated according to the stored values.
    def ensure_encrypted_attributes
      self.class.encrypted_attributes.each do |attr|
        send("#{attr}=", send(attr))
      end
    end

    def decrypt_value(value)
      Decidim::AttributeEncryptor.decrypt(value)
    rescue ActiveSupport::MessageEncryptor::InvalidMessage, ActiveSupport::MessageVerifier::InvalidSignature
      # Support for legacy unencrypted values. This is necessary e.g. when
      # migrating the original unencrypted values to encrypted values.
      value
    end

    def encrypt_value(value)
      Decidim::AttributeEncryptor.encrypt(value)
    end

    def decrypt_hash_values(hash)
      return hash unless hash.is_a?(Hash)

      hash.transform_values do |value|
        # If the value is not a String, it is likely a legacy unencrypted hash
        # value. Also, `ActiveSupport::JSON.decode` expects the value passed to
        # it to be a String. Otherwise it would raise a TypeError.
        next value unless value.is_a?(String)

        decrypted_value = decrypt_value(value)

        # When handling legacy unencrypted hash values, the decrypted values
        # could not be valid JSON strings. They could be normal strings that
        # cannot be JSON decoded.
        begin
          ActiveSupport::JSON.decode(decrypted_value)
        rescue TypeError
          ""
        rescue JSON::ParserError
          decrypted_value
        end
      end
    end

    def encrypt_hash_values(hash)
      return hash unless hash.is_a?(Hash)

      # The values are stored in JSON encoded format in order to match the
      # PostgreSQL adapter's default functionality as you can see at:
      # https://git.io/JkdYJ
      hash.transform_values { |value| encrypt_value(ActiveSupport::JSON.encode(value)) }
    end
  end
end
