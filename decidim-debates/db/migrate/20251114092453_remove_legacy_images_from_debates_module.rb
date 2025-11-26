# frozen_string_literal: true

class RemoveLegacyImagesFromDebatesModule < ActiveRecord::Migration[7.2]
  def change
    remove_column :decidim_debates_debates, :image, :string
  end
end
