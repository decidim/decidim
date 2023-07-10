# frozen_string_literal: true

class ChangeStatesOnAmendments < ActiveRecord::Migration[6.1]
  class Amendment < ApplicationRecord
    self.table_name = :decidim_amendments
    STATES = { draft: 0, evaluating: 10, accepted: 20, rejected: 30, withdrawn: -1 }.freeze
  end

  def up
    rename_column :decidim_amendments, :state, :old_state
    add_column :decidim_amendments, :state, :integer, default: 0, null: false

    Amendment.reset_column_information

    Amendment::STATES.each_pair do |status, index|
      Amendment.where(old_state: status).update_all(state: index) # rubocop:disable Rails/SkipsModelValidations
    end

    remove_column :decidim_amendments, :old_state
  end

  def down
    rename_column :decidim_amendments, :state, :old_state
    add_column :decidim_amendments, :state, :string, default: "draft", null: false

    Amendment.reset_column_information

    Amendment::STATES.each_pair do |status, index|
      Amendment.where(old_state: index).update_all(state: status) # rubocop:disable Rails/SkipsModelValidations
    end

    remove_column :decidim_amendments, :old_state
  end
end
