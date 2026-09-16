# frozen_string_literal: true

class FixResultFollows < ActiveRecord::Migration[5.2]
  def change
    # rubocop:disable-next Rails/SkipsModelValidations
    Decidim::Follow.where(decidim_followable_type: "Decidim::Results::Result").update_all(decidim_followable_type: "Decidim::Accountability::Result")
  end
end
