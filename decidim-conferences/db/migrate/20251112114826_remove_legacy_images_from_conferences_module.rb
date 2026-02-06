# frozen_string_literal: true

class RemoveLegacyImagesFromConferencesModule < ActiveRecord::Migration[7.2]
  def change
    remove_column :decidim_conferences, :hero_image, :string
    remove_column :decidim_conferences, :banner_image, :string
    remove_column :decidim_conferences, :main_logo, :string
    remove_column :decidim_conferences, :signature, :string

    remove_column :decidim_conference_speakers, :avatar, :string
    remove_column :decidim_conferences_partners, :logo, :string
  end
end
