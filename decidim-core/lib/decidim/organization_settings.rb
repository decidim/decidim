# frozen_string_literal: true

module Decidim
  #
  # Takes care of holding and accessing organization settings for each
  # organization or the default organization.
  #
  class OrganizationSettings < OpenStruct
    class << self
      # Fetches or creates a settings object for the given organization.
      #
      # @param organization [Decidim::Organization] The organization in
      #   question.
      # @return [Decidim::OrganizationSettings] The settings object.
      def for(organization)
        # Before the organization has an ID attached to it, it cannot be stored
        # to the registry.
        return new(organization) if organization.new_record?

        @registry ||= {}
        @registry[organization.id] ||= new(organization)
      end

      # Reloads the settings object for a given organization. Should be called
      # when the configurations have changed and need to be reloaded.
      #
      # @param organization [Decidim::Organization] The organization in question.
      # @return [Decidim::OrganizationSettings] The settings object.
      def reload(organization)
        @registry.delete(organization.id) if @registry
        self.for(organization)
      end

      # The settings should be reset during the tests in order for the new tests
      # to always load the latest settings. The results of the previous tests
      # should not affect the settings of the following test.
      def reset!
        @registry = {}
      end

      # Returns the default configuration value for the given setting key chain.
      #
      # For example:
      #
      #   Decidim::OrganizationSettings.default(:upload, :maximum_file_size, :default)
      #   #=> 10
      #
      # Note: this cannot fetch the default settings from the class instance
      # variable "defaults" because that would cause an infinite loop.
      #
      # @param *chain [Symbol, String] The configuration key(s) to dig into
      #   inside the default configurations hash.
      # @return The value found from the default configurations hash.
      def default(*chain)
        return if chain.blank?

        configs = defaults_hash
        while (lookup = chain.shift)
          configs = configs[lookup.to_s]
          return configs if chain.empty?
          return unless configs.is_a?(Hash)
        end

        nil
      end

      # This is a class level helper to get a "dummy" default settings object
      # that responds to the same methods as the normal organization specific
      # settings objects. This allows for the following kind of syntactic sugar:
      #
      #   settings = Decidim::OrganizationSettings.for(actual_org)
      #   settings.target_config_accessor #=> returns the organization setting
      #
      #   settings = Decidim::OrganizationSettings.defaults
      #   settings.target_config_accessor #=> returns the default setting
      #
      # This can be used through the Decidim module as follows:
      #
      #   Decidim.organization_settings(org).target_config_accessor
      #   #=> returns the organization specific setting
      #
      #   Decidim.organization_settings(model_belonging_to_org).target_config_accessor
      #   #=> returns the organization specific setting for model's organization
      #
      #   Decidim.organization_settings(nil).target_config_accessor
      #   #=> returns the default setting
      #
      # @return [Decidim::OrganizationSettings] The default settings object.
      def defaults
        @defaults ||= new(OpenStruct.new)
      end

      private

      # Stores the default settings hash which is used to create the settings
      # objects. This will provide all the missing configuration values for the
      # final object if it does not define some of the values.
      #
      # Note: This cannot be stored in a class variable because it would change
      # the arrays into comma separated strings.
      #
      # @return [Hash] The default settings hash.
      def defaults_hash
        {
          "upload" => {
            "allowed_file_extensions" => {
              "default" => %w(jpg jpeg png webp pdf rtf txt),
              "admin" => %w(jpg jpeg png webp pdf doc docx xls xlsx ppt pptx ppx rtf txt odt ott odf otg ods ots csv json md),
              "image" => %w(jpg jpeg png webp)
            },
            "allowed_content_types" => {
              "default" => %w(
                image/*
                application/pdf
                application/rtf
                text/plain
              ),
              "admin" => %w(
                image/*
                application/vnd.oasis.opendocument
                application/vnd.ms-*
                application/msword
                application/vnd.ms-word
                application/vnd.openxmlformats-officedocument
                application/vnd.oasis.opendocument
                application/pdf
                application/rtf
                application/json
                text/markdown
                text/plain
                text/csv
              )
            },
            "maximum_file_size" => {
              "default" => Decidim.maximum_attachment_size.to_f,
              "avatar" => Decidim.maximum_avatar_size.to_f
            }
          }
        }
      end
    end

    def initialize(organization)
      # This maps the local configuration top level keys to the methods/column
      # names in the organization model that provide the values for these
      # settings.
      keys_map = { upload: :file_upload_settings }

      # Pass a configuration hash to the parent constructor that combines the
      # default settings with the organization level settings. This ensures that
      # all configurations have values even when the organization settings do
      # not define them.
      super(
        keys_map.to_h do |config, method|
          [
            config.to_s,
            generate_config(
              organization.public_send(method) || {},
              self.class.default(config)
            )
          ]
        end
      )

      keys_map.keys.each do |config|
        define_config_accessors(public_send(config), [config])
      end
    end

    def wrap_upload_maximum_file_size(value)
      value.megabytes
    end

    def wrap_upload_maximum_file_size_avatar(value)
      value.megabytes
    end

    def wrap_upload_allowed_content_types(value)
      content_type_array(value)
    end

    def wrap_upload_allowed_content_types_admin(value)
      content_type_array(value)
    end

    private

    # Generates a final settings configuration struct from the given settings
    # hash. Combines the given defaults with the settings hash.
    #
    # @param hash [Hash] The configurations hash.
    # @param default [Hash] The default configurations.
    # @return [OpenStruct] The configuration struct.
    def generate_config(hash, default = {})
      OpenStruct.new(
        default.deep_merge(hash).to_h do |key, value|
          value = generate_config(value) if value.is_a?(Hash)
          [key, value]
        end
      )
    end

    # Turns the stars into wildcard regular expression matches in the matching
    # strings.
    #
    # @param [Array<String>] An array of glob strings to match against.
    # @return [Array<Regexp>] An array of regular expressions to match against.
    def content_type_array(types)
      types.map do |match_string|
        Regexp.new(Regexp.escape(match_string).gsub("\\*", ".*?"))
      end
    end

    # This defines all the config accessors for the configuration parameters
    # that can be directly called for the settings instance without having to
    # "drill down" to the child structs. For example, if the whole settings
    # object was initialized with the following hash:
    #
    #   {
    #     "upload" => {
    #       "allowed_file_extensions" => {
    #         "default" => %w(jpg jpeg),
    #         "admin" => %w(jpg jpeg png)
    #       }
    #     },
    #     "another_thing" => {
    #       "bleep" => "bloop",
    #       "foo" => {
    #         "bar" => 1
    #         "baz" => 2
    #       }
    #     }
    #   }
    #
    # This would automatically generate the following methods in the settings
    # instance:
    #
    #   - upload_allowed_file_extensions #=> ["jpg", "jpeg"]
    #   - upload_allowed_file_extensions_admin #=> ["jpg", "jpeg", "png"]
    #   - another_thing_bleep #=> "bloop"
    #   - another_thing_foo_bar #=> 1
    #   - another_thing_foo_baz #=> 2
    #
    # Note that when the deepest configuration hash has the key "default", it
    # will not be appended to the method name.
    #
    # @param obj [Decidim::OrganizationSettings, OpenStruct] The settings object
    #   for which to define the accessors.
    # @param chain [Array<Symbol>] The current lookup chain for the settings
    #   object. Needed when called recursively.
    def define_config_accessors(obj, chain)
      obj.each_pair do |key, val|
        if val.is_a?(OpenStruct)
          define_config_accessors(val, [*chain, key])
        else
          prefix = chain.join("_")
          method = prefix
          method = "#{method}_#{key}" unless key.to_sym == :default

          define_singleton_method(method) do
            value = dig(*chain, key)
            return value unless respond_to?("wrap_#{method}")

            public_send("wrap_#{method}", value)
          end
        end
      end
    end
  end
end
