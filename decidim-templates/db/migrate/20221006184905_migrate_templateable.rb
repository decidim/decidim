class MigrateTemplateable < ActiveRecord::Migration[6.0]
  def self.up
    Decidim::Templates::Template.find_each do |template|
      template.update_attribute(:target, template.templatable_type.demodulize.tableize.singularize)
    end
  end

  def self.down
  end
end
