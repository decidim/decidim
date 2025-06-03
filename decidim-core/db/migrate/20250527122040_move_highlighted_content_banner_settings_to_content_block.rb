# frozen_string_literal: true

class MoveHighlightedContentBannerSettingsToContentBlock < ActiveRecord::Migration[7.0]
  class Organization < ApplicationRecord
    self.table_name = :decidim_organizations
  end

  def up
    Organization.reset_column_information
    # Note that we need to use the actual Decidim::ContentBlock clas, as we need access to the `images_container` method
    Decidim::ContentBlock.reset_column_information

    Organization.find_each do |organization|
      content_block = Decidim::ContentBlock.find_by(organization: organization, scope_name: :homepage, manifest_name: :highlighted_content_banner)
      settings = {}

      title = organization.highlighted_content_banner_title || {}
      settings = title.inject(settings) { |acc, (k, v)| acc.update("title_#{k}" => v) }

      short_description = organization.highlighted_content_banner_short_description || {}
      settings = short_description.inject(settings) { |acc, (k, v)| acc.update("short_description_#{k}" => v) }

      action_button_title = organization.highlighted_content_banner_action_title || {}
      settings = action_button_title.inject(settings) { |acc, (k, v)| acc.update("action_button_title_#{k}" => v) }

      action_button_subtitle = organization.highlighted_content_banner_action_subtitle || {}
      settings = action_button_subtitle.inject(settings) { |acc, (k, v)| acc.update("action_button_subtitle_#{k}" => v) }

      action_button_url = organization.highlighted_content_banner_action_url || ""
      settings["action_button_url"] = action_button_url

      # We need to do a workaround for getting the image, as ActiveStorage is polymorphic and expects that the `record_type` is the class name of the model
      background_image = ActiveStorage::Attachment.find_by(name: "highlighted_content_banner_image", record_type: "Decidim::Organization", record_id: organization.id)
      content_block.images_container.background_image = background_image.blob if background_image

      content_block.settings = settings
      content_block.settings_will_change!
      content_block.save!
    end

    remove_column :decidim_organizations, :highlighted_content_banner_enabled
    remove_column :decidim_organizations, :highlighted_content_banner_title
    remove_column :decidim_organizations, :highlighted_content_banner_short_description
    remove_column :decidim_organizations, :highlighted_content_banner_action_title
    remove_column :decidim_organizations, :highlighted_content_banner_action_subtitle
    remove_column :decidim_organizations, :highlighted_content_banner_action_url
    remove_column :decidim_organizations, :highlighted_content_banner_image
  end

  def down
    add_column :decidim_organizations, :highlighted_content_banner_enabled, :boolean, null: false, default: false
    add_column :decidim_organizations, :highlighted_content_banner_title, :jsonb
    add_column :decidim_organizations, :highlighted_content_banner_short_description, :jsonb
    add_column :decidim_organizations, :highlighted_content_banner_action_title, :jsonb
    add_column :decidim_organizations, :highlighted_content_banner_action_subtitle, :jsonb
    add_column :decidim_organizations, :highlighted_content_banner_action_url, :string
    add_column :decidim_organizations, :highlighted_content_banner_image, :string
  end
end
