# frozen_string_literal: true

class MigrateTemplateable < ActiveRecord::Migration[6.0]
  def self.up
    # rubocop:disable Rails/SkipsModelValidations
    Decidim::Templates::Template.where(templatable_type: "Decidim::Forms::Questionnaire").update_all(target: "questionnaire")
    Decidim::Templates::Template.where(templatable_type: "Decidim::Organization").update_all(target: "user_block")
    # rubocop:enable Rails/SkipsModelValidations
  end
end
