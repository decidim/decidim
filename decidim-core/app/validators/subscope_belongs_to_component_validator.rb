# frozen_string_literal: true

# This validator ensures the scope is a subscope of a component scope,
class SubscopeBelongsToComponentValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless record.component

    record.errors.add(attribute, :invalid) unless record.component.subscopes.where(id: value).exists?
  end
end
