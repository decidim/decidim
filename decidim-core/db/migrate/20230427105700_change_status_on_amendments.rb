# frozen_string_literal: true

class ChangeStatusOnAmendments < ActiveRecord::Migration[6.1]
  class Amendment < ApplicationRecord
    self.table_name = :decidim_amendments
    STATES = %w(draft evaluating accepted rejected withdrawn).freeze
  end

  def up
    rename_column :decidim_amendments, :state, :old_state
    add_column :decidim_amendments, :state, :integer, default: 0, null: false

    Amendment.reset_column_information

    Amendment.find_each do |amendment|
      amendment.update(state: Amendment::STATES.index(amendment.old_state))
    end

    remove_column :decidim_amendments, :old_state
    Amendment.reset_column_information
  end

  def down
    rename_column :decidim_amendments, :state, :old_state
    add_column :decidim_amendments, :state, :string, default: "draft", null: false
    Amendment.reset_column_information
    Amendment.find_each do |amendment|
      amendment.update(state: Amendment::STATES[amendment.old_state])
    end
    remove_column :decidim_amendments, :old_state
    Amendment.reset_column_information
  end
end
