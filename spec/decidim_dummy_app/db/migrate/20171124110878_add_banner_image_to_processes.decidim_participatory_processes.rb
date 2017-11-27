# This migration comes from decidim_participatory_processes (originally 20161011141033)
# frozen_string_literal: true

class AddBannerImageToProcesses < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_participatory_processes, :banner_image, :string
  end
end
