# frozen_string_literal: true

# This validator takes care of ensuring the validated attributes are long enough
# and not too long. The difference to the Rails length validator is that this
# allows the minimum and maximum values to be lambdas allowing us to fetch the
# maximum length dynamically for each proposals component.
class ProposalLengthValidator < ActiveModel::EachValidator
  include ActionView::Helpers::SanitizeHelper

  def validate_each(record, attribute, value)
    return if value.blank?

    text_value = strip_tags(value)
    validate_min_length(record, attribute, text_value)
    validate_max_length(record, attribute, text_value)
  end

  private

  def validate_min_length(record, attribute, value)
    min = options[:minimum] || nil
    min = min.call(record) if min.respond_to?(:call)
    if min && min.positive? && value.length < min
      record.errors.add(
        attribute,
        options[:message] || :too_short,
        count: min
      )
    end
  end

  def validate_max_length(record, attribute, value)
    max = options[:maximum] || nil
    max = max.call(record) if max.respond_to?(:call)
    if max && max.positive? && value.length > max
      record.errors.add(
        attribute,
        options[:message] || :too_long,
        count: max
      )
    end
  end
end
