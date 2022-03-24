# frozen_string_literal: true

# A custom validator to make sure components are correctly assigned to a model.
#
# Adds a presence validation and checks that the manifest is the correct one.
class ComponentValidator < ActiveModel::EachValidator
  # Validates the arguiments passed to the validator.
  def check_validity!
    raise ArgumentError, "You must include a `manifest` option with the name of the manifest to validate when validating a component" if options[:manifest].blank?
  end

  # The actual validator method. It is called when ActiveRecord iterates
  # over all the validators.
  def validate_each(record, attribute, component)
    unless component
      record.errors.add(attribute, :blank)
      return
    end

    record.errors.add(attribute, :invalid) if component.manifest_name.to_s != options[:manifest].to_s
  end
end
