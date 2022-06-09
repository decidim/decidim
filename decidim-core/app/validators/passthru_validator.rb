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
  # record - Form object (e.g. Decidim::UploadValidationForm)
  # attribute - The attribute to validate (e.g. :avatar)
  # value - Blob's signed id (e.g. "eyJfcmFpbHMi...")
  def validate_each(record, attribute, value)
    return unless target_class

    dummy_attr = target_attribute(attribute)

    # Create a dummy record for which the validations are actually run on
    dummy = validation_record(record)
    if dummy.respond_to?(dummy_attr) && !(value.class <= ActiveStorage::Attached)
      dummy.public_send("#{dummy_attr}=", value)
      value = dummy.public_send(dummy_attr)
    elsif dummy.respond_to? :file
      dummy.public_send("file=", value)
      value = dummy.public_send(:file)
    end

    target_validators(attribute).each do |validator|
      next unless validator.is_a?(ActiveModel::EachValidator)
      next unless check_validator_conditions(dummy, validator)

      dummy.errors.clear

      validator.validate_each(dummy, dummy_attr, value)
      dummy.errors[dummy_attr].each do |err|
        record.errors.add(attribute, err)
      end
    end
  end

  # Creates a dummy validation record that passes the correct file upload
  # validation context from the original record for the validators.
  def validation_record(record)
    dummy = target_instance(record)
    if dummy.is_a?(Decidim::Attachment)
      if record.respond_to?(:attached_to)
        dummy.attached_to = record.attached_to
      elsif record.respond_to?(:organization)
        dummy.attached_to = record.organization
      end
    elsif dummy.respond_to?(:organization=) && record.respond_to?(:organization)
      dummy.organization = record.organization
    end
    dummy
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

  def target_instance(record)
    instance_attributes = if options[:with].respond_to?(:call)
                            options[:with].call(record)
                          else
                            options[:with] || {}
                          end

    instance_attributes.each do |key, val|
      instance_attributes[key] = val.call(record) if val.respond_to?(:call)
    end

    target_class.new(instance_attributes)
  end

  private

  def check_validator_conditions(record, validator)
    if (condition = validator.options[:if])
      if_result = if condition.respond_to?(:call)
                    condition.call(record)
                  else
                    record.public_send(condition)
                  end

      return false unless if_result
    end

    if (condition = validator.options[:unless])
      unless_result = if condition.respond_to?(:call)
                        condition.call(record)
                      else
                        record.public_send(condition)
                      end

      return false if unless_result
    end

    true
  end
end
