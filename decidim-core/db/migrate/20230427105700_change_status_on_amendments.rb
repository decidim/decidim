# frozen_string_literal: true

class ChangeStatusOnAmendments < ActiveRecord::Migration[6.1]
  def up
    rename_column :decidim_amendments, :state, :old_state
    add_column :decidim_amendments, :state, :integer, default: 0, null: false

    Decidim::Amendment.reset_column_information

    Decidim::Amendment.find_each do |amendment|
      amendment.update(state: Decidim::Amendment::STATES.index(amendment.old_state))
    end

    remove_column :decidim_amendments, :old_state
    Decidim::Amendment.reset_column_information
  end

  def down
    rename_column :decidim_amendments, :state, :old_state
    add_column :decidim_amendments, :state, :string, default: "draft", null: false
    Decidim::Amendment.reset_column_information
    Decidim::Amendment.find_each do |amendment|
      amendment.update(state: Decidim::Amendment::STATES[amendment.old_state])
    end
    remove_column :decidim_amendments, :old_state
    Decidim::Amendment.reset_column_information
  end
end
