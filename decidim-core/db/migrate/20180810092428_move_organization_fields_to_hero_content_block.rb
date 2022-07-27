# frozen_string_literal: true

class MoveOrganizationFieldsToHeroContentBlock < ActiveRecord::Migration[5.2]
  # This migration made use CarrierWave, which in future will be eliminated.
  # The organization homepage image was moved to the content block background
  # image using CarrierWave. This operation has been removed, so if there is
  # an existing homepage image previous to this migration the content block
  # background image should be loaded manually
  class Organization < ApplicationRecord
    self.table_name = :decidim_organizations
  end

  def change
    Decidim::ContentBlock.reset_column_information
    Organization.find_each do |organization|
      content_block = Decidim::ContentBlock.find_by(organization:, scope: :homepage, manifest_name: :hero)
      settings = {}
      welcome_text = organization.welcome_text || {}
      settings = welcome_text.inject(settings) { |acc, (k, v)| acc.update("welcome_text_#{k}" => v) }

      content_block.settings = settings
      content_block.settings_will_change!
      content_block.save!
    end

    remove_column :decidim_organizations, :welcome_text
    remove_column :decidim_organizations, :homepage_image
  end
end
