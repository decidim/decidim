# frozen_string_literal: true

class FixUserFollows < ActiveRecord::Migration[5.2]
  class Follow < ApplicationRecord
    self.table_name = "decidim_follows"

    belongs_to :followable, foreign_key: "decidim_followable_id", foreign_type: "decidim_followable_type", polymorphic: true
    belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User"
  end

  def change
    # rubocop:disable Rails/SkipsModelValidations
    Follow.where(
      decidim_followable_type: "Decidim::User"
    ).update_all(decidim_followable_type: "Decidim::UserBaseEntity")
    # rubocop:enable Rails/SkipsModelValidations
  end
end
