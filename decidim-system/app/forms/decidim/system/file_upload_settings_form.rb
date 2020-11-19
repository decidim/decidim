# frozen_string_literal: true

module Decidim
  module System
    # A form object used to update organization file upload settings from the
    # system dashboard.
    #
    class FileUploadSettingsForm < Form
      include JsonbAttributes

      mimic :organization_file_uploads

      attribute :allowed_file_extensions, Hash[Symbol => String]
      attribute :allowed_content_types, Hash[Symbol => String]
      attribute :maximum_file_size, Hash[Symbol => Float]

      def map_model(settings_hash)
        settings_hash = begin
          if settings_hash.is_a?(Hash)
            default_settings.deep_merge(settings_hash.deep_stringify_keys)
          else
            default_settings
          end
        end

        attribute_set.each do |attr|
          key = attr.name.to_s
          next unless settings_hash.has_key?(key)

          # For the view, the array values need to be in comma separated format
          # in order for them to work correctly with the tags inputs.
          value = Rectify::FormAttribute.new(attr).value_from(
            settings_hash[key]
          )
          value.each do |k, v|
            value[k] = v.join(",") if v.is_a?(Array)
          end

          self[key] = value
        end
      end

      # This turns the attributes passed from the view into the final
      # configuration array. Due to the UI component used for the array values,
      # those values need to be handled as a single comma separated string in
      # the view layer. Before we save those attributes, they need to be
      # converted into arrays which is what this method does.
      def final
        csv_attributes = [:allowed_file_extensions, :allowed_content_types]
        attributes.tap do |attr|
          csv_attributes.each do |key|
            attr[key] = csv_array_setting(attr[key])
          end
        end
      end

      private

      def default_settings
        Decidim::OrganizationSettings.default(:upload)
      end

      def csv_array_setting(original)
        original.transform_values do |value|
          value.split(",")
        end
      end
    end
  end
end
