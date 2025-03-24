# frozen_string_literal: true

class DropDecidimMetrics < ActiveRecord::Migration[7.0]
  def change
    drop_table :decidim_metrics, if_exists: true
  end
end
