# frozen_string_literal: true

class AddReportedContentToModerations < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_moderations, :reported_content, :text
  end
end
