# frozen_string_literal: true

class AllowMultipleOfflineVotes < ActiveRecord::Migration[5.2]
  class InitiativesTypeScope < ApplicationRecord
    self.table_name = :decidim_initiatives_type_scopes
  end

  class Initiative < ApplicationRecord
    self.table_name = :decidim_initiatives

    belongs_to :scoped_type,
               foreign_key: "scoped_type_id",
               class_name: "InitiativesTypeScope"
  end

  def change
    rename_column :decidim_initiatives, :offline_votes, :old_offline_votes
    add_column :decidim_initiatives, :offline_votes, :jsonb, default: {}

    Initiative.reset_column_information

    Initiative.includes(:scoped_type).find_each do |initiative|
      scope_key = (initiative&.scoped_type&.decidim_scopes_id || "global").to_s

      offline_votes = {
        scope_key => initiative.old_offline_votes.to_i,
        "total" => initiative.old_offline_votes.to_i
      }

      # rubocop:disable Rails/SkipsModelValidations
      initiative.update_column(:offline_votes, offline_votes)
      # rubocop:enable Rails/SkipsModelValidations
    end

    remove_column :decidim_initiatives, :old_offline_votes
  end
end
