# coding: utf-8
class EtiquetteValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    validate_caps(record, attribute, value)
    validate_marks(record, attribute, value)
    validate_long_words(record, attribute, value)
    validate_caps_first(record, attribute, value)
  end

  private

  def validate_caps(record, attribute, value)
    if value.scan(/[A-Z]/).length > value.length / 3
      record.errors.add(attribute, options[:message] || :too_much_caps)
    end
  end

  def validate_marks(record, attribute, value)
    if value.scan(/[!?¡¿]{2,}/).length > 0
      record.errors.add(attribute, options[:message] || :too_many_marks)
    end
  end

  def validate_long_words(record, attribute, value)
    if value.scan(/[A-z]{30,}/).length > 0
      record.errors.add(attribute, options[:message] || :long_words)
    end
  end

  def validate_caps_first(record, attribute, value)
    if value.scan(/^[a-z]{1}/).length > 0
      record.errors.add(attribute, options[:message] || :must_start_with_caps)
    end
  end

  def validate_length(record, attribute, value)
    if value.length < 15
      record.errors.add(attribute, options[:message] || :too_short)
    end
  end
end
