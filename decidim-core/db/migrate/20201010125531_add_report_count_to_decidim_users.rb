# frozen_string_literal: true

class AddReportCountToDecidimUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_users, :report_count, :integer, default: 0
  end
end
