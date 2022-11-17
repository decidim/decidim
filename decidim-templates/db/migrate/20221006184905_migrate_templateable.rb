# frozen_string_literal: true

class MigrateTemplateable < ActiveRecord::Migration[6.0]
  class Template < ApplicationRecord
    self.table_name = :decidim_templates_templates
  end

  def self.up
    # rubocop:disable Rails/SkipsModelValidations
    Template.where(templatable_type: "Decidim::Forms::Questionnaire").update_all(target: "questionnaire")
    Template.where(templatable_type: "Decidim::Organization").update_all(target: "user_block")
    # rubocop:enable Rails/SkipsModelValidations
  end
end
