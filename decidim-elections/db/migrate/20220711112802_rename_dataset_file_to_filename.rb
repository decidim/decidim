# frozen_string_literal: true

class RenameDatasetFileToFilename < ActiveRecord::Migration[6.1]
  def change
    rename_column :decidim_votings_census_datasets, :file, :filename
  end
end
