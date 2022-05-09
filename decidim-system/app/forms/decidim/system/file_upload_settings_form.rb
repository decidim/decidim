# frozen_string_literal: true

module Decidim
  module System
    # A form object used to update organization file upload settings from the
    # system dashboard.
    #
    class FileUploadSettingsForm < Form
      include JsonbAttributes

      mimic :organization_file_uploads

      attribute(:allowed_file_extensions, { Symbol => String })
      attribute(:allowed_content_types, { Symbol => String })
      attribute(:maximum_file_size, { Symbol => Float })

      def map_model(settings_hash)
        settings_hash = if settings_hash.is_a?(Hash)
                          default_settings.deep_merge(settings_hash.deep_stringify_keys)
                        else
                          default_settings
                        end

        csv_attributes.each do |attr|
          next unless settings_hash.has_key?(attr.to_s)

          # For the view, the array values need to be in comma separated format
          # in order for them to work correctly with the tags inputs.
          value = settings_hash[attr.to_s]
          value.each do |k, v|
            value[k] = v.join(",") if v.is_a?(Array)
          end

          send("#{attr}=", value)
        end

        self.maximum_file_size = settings_hash["maximum_file_size"]
      end

      # This turns the attributes passed from the view into the final
      # configuration array. Due to the UI component used for the array values,
      # those values need to be handled as a single comma separated string in
      # the view layer. Before we save those attributes, they need to be
      # converted into arrays which is what this method does.
      def final
        to_h.tap do |attr|
          csv_attributes.each do |key|
            attr[key] = csv_array_setting(attr[key])
          end
        end
      end

      private

      def default_settings
        Decidim::OrganizationSettings.default(:upload)
      end

      def csv_attributes
        @csv_attributes ||= [:allowed_file_extensions, :allowed_content_types]
      end

      def csv_array_setting(original)
        original.transform_values do |value|
          value.split(",")
        end
      end
    end
  end
end
