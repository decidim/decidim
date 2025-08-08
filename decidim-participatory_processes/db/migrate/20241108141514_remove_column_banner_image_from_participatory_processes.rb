# frozen_string_literal: true

class RemoveColumnBannerImageFromParticipatoryProcesses < ActiveRecord::Migration[7.0]
  def change
    remove_column :decidim_participatory_processes, :banner_image, :string
  end
end
