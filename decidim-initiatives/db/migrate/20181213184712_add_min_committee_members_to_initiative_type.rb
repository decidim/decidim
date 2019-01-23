# frozen_string_literal: true

class AddMinCommitteeMembersToInitiativeType < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_initiatives_types, :minimum_committee_members, :integer, null: true, default: nil
  end
end
