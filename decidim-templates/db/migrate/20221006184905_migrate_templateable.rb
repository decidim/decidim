# frozen_string_literal: true

class MigrateTemplateable < ActiveRecord::Migration[6.0]
  def self.up
    Decidim::Templates::Template.find_each do |template|
      next if template.templatable_type.blank?

      template.update(target: template.templatable_type.demodulize.tableize.singularize)
    end
  end

  def self.down; end
end
