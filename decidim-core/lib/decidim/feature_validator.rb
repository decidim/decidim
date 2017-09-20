# frozen_string_literal: true

# A custom validator to make sure features are correctly assigned to a model.
#
# Adds a presence validation and checks that the manifest is the correct one.
class FeatureValidator < ActiveModel::EachValidator
  # Validates the arguiments passed to the validator.
  def check_validity!
    raise ArgumentError, "You must include a `manifest` option with the name of the manifest to validate when validating a feature" if options[:manifest].blank?
  end

  # The actual validator method. It is called when ActiveRecord iterates
  # over all the validators.
  def validate_each(record, attribute, feature)
    unless feature
      record.errors[attribute] << :blank
      return
    end

    record.errors[attribute] << :invalid if feature.manifest_name.to_s != options[:manifest].to_s
  end
end
