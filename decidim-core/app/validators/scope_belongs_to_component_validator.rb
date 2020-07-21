# frozen_string_literal: true

# This validator ensures the scope is a scope of a component scope
class ScopeBelongsToComponentValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless component_for(record)

    record.errors.add(attribute, :invalid) if component_for(record).out_of_scope?(Decidim::Scope.find_by(id: value))
  end

  private

  def component_for(record)
    record.try(:component) || record.try(:current_component)
  end
end
