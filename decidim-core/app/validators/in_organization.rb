module Decidim
  class FeatureValidator < ActiveModel::EachValidator
    def initialize(options)
      raise "You must include a `manifest` option with the name of the manifest to validate when validating a feature" unless options[:manifest]
      super
    end

    def validate_each(record, attribute, feature)
      unless feature
        record.errors[attribute] << :taken
        return
      end

      record.errors[attribute] << :invalid if feature.manifest_name.to_s != options[:manifest].to_s
    end
  end
end
