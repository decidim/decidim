# frozen_string_literal: true

class MoveOrganizationFieldsToHeroContentBlock < ActiveRecord::Migration[5.2]
  class Organization < ApplicationRecord
    self.table_name = :decidim_organizations

    mount_uploader :homepage_image, ::Decidim::HomepageImageUploader
  end

  def change
    Organization.find_each do |organization|
      content_block = Decidim::ContentBlock.find_by(organization: organization, scope: :homepage, manifest_name: :hero)
      settings = {}
      welcome_text = organization.welcome_text || {}
      settings = welcome_text.inject(settings) { |acc, (k, v)| acc.update("welcome_text_#{k}" => v) }

      content_block.settings = settings
      content_block.images_container.background_image = organization.homepage_image.file
      content_block.save!
    end

    remove_column :decidim_organizations, :welcome_text
    remove_column :decidim_organizations, :homepage_image
  end
end
