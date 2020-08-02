# frozen_string_literal: true

# This validator passes through the file upload validations on a record
# attribute to an associated record. Useful e.g. with the forms that are not
# aware of the actual record's validators but they still need to apply the same
# validators as in the model they represent. Needs to be configured with the
# target class and optionally the target attribute where the validators are
# fetched from. By default the attribute name matches the attribute the
# validator is set for. Works only for each validators.
#
# Example:
#
#   class ParticipantForm < Decidim::Form
#     # Passes both the validator class only
#     validates :avatar_image, passthru: { to: Person }
#
#     # Passes both the validator class and attribute
#     validates :image, passthru: { to: Person, attribute: :avatar_image }
#   end
class PassthruValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless target_class

    dummy_attr = target_attribute(attribute)

    # Create a dummy record for which the validations are actually run on
    dummy = target_class.new

    # Pass the organization to the dummy record if possible and set for the
    # record.
    if record.respond_to?(:organization)
      if dummy.is_a?(Decidim::Attachment)
        dummy.attached_to = record.organization
      elsif dummy.respond_to?(:organization)
        dummy.organization = record.organization
      end
    end

    target_validators(attribute).each do |validator|
      next unless validator.is_a?(ActiveModel::EachValidator)

      dummy.errors.clear
      validator.validate_each(dummy, dummy_attr, value)
      dummy.errors[dummy_attr].each do |err|
        record.errors.add(attribute, err)
      end
    end
  end

  def target_validators(attribute)
    target_class.validators_on(target_attribute(attribute))
  end

  def target_class
    options[:to]
  end

  def target_attribute(default = nil)
    options[:attribute] || default
  end
end
