# This migration comes from decidim_participatory_processes (originally 20161107152228)
# frozen_string_literal: true

class RemoveNotNullOnStepPosition < ActiveRecord::Migration[5.0]
  def change
    change_column :decidim_participatory_process_steps, :position, :integer, null: true
  end
end
