# frozen_string_literal: true

class RemoveLegacyImagesFromParticipatoryProcessesModule < ActiveRecord::Migration[7.2]
  def change
    remove_column :decidim_participatory_processes, :hero_image, :string

    remove_column :decidim_participatory_process_groups, :hero_image, :string
  end
end
