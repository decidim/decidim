# frozen_string_literal: true

require "decidim/has_class_extends"

class FixReferenceForAllResources < ActiveRecord::Migration[5.1]
  def up
    models = ActiveRecord::Base.descendants.select { |c| (c.included_modules.include?(Decidim::HasReference) && !c.included_modules.include?(Decidim::HasClassExtends)) }

    models.each do |model|
      model.find_each(&:touch)
    end
  end

  def down; end
end
