# frozen_string_literal: true

class RemoveMetricsContentBlocks < ActiveRecord::Migration[7.0]
  def up
    Decidim::ContentBlock.where(manifest_name: "metrics").destroy_all
  end

  def down; end
end
