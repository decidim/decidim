# frozen_string_literal: true

# This validator takes care of ensuring the validated attributes are long enough
# and not too long. The difference to the Rails length validator is that this
# allows the minimum and maximum values to be lambdas allowing us to fetch the
# maximum length dynamically for each proposals component.
class ProposalLengthValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    validate_length(record, attribute, value)
  end

  private

  def validate_length(record, attribute, value)
    min = options[:minimum] || nil
    min = min.call(record) if min.respond_to?(:call)
    if min && min > 0 && value.length < min
      record.errors.add(attribute, options[:message] || :too_short)
    end

    max = options[:maximum] || nil
    max = max.call(record) if max.respond_to?(:call)
    if max && max > 0 && value.length > max
      record.errors.add(attribute, options[:message] || :too_long)
    end
  end
end
