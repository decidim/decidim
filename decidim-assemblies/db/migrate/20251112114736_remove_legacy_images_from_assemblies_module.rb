# frozen_string_literal: true

class RemoveLegacyImagesFromAssembliesModule < ActiveRecord::Migration[7.2]
  def change
    remove_column :decidim_assemblies, :hero_image, :string
    remove_column :decidim_assemblies, :banner_image, :string
  end
end
