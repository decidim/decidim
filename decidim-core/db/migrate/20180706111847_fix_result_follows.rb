# frozen_string_literal: true

class FixResultFollows < ActiveRecord::Migration[5.2]
  def change
    # rubocop:disable Rails/SkipsModelValidations
    Decidim::Follow.where(decidim_followable_type: "Decidim::Results::Result").update_all(decidim_followable_type: "Decidim::Accountability::Result")
    # rubocop:enable Rails/SkipsModelValidations
  end
end
