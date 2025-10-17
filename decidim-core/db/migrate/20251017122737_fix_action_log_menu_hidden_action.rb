# frozen_string_literal: true

class FixActionLogMenuHiddenAction < ActiveRecord::Migration[7.2]
  class ActionLog < ApplicationRecord
    self.table_name = :decidim_action_logs
  end

  def change
    ActionLog.where(action: "menu_hidden").find_each do |action_log|
      action_log.update_column(:visibility, "admin-only") # rubocop:disable Rails/SkipsModelValidations
    end
  end
end
