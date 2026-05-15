# frozen_string_literal: true

class RemoveLegacyImagesFromInitiativesModule < ActiveRecord::Migration[7.2]
  def change
    remove_column :decidim_initiatives_types, :banner_image, :string
  end
end
