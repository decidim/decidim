# frozen_string_literal: true

class AddShortNameToOrganizations < ActiveRecord::Migration[7.2]
  class Organization < ApplicationRecord
    self.table_name = "decidim_organizations"
  end

  def up
    Organization.find_each do |organization|
      # Skip if short_name is already populated
      next if organization.short_name.present? && organization.short_name != {}

      next if organization.name.blank?

      short_name_hash = {}
      organization.name.each do |locale, name_value|
        # Skip machine_translations and other nested hashes
        next if name_value.is_a?(Hash)
        next if name_value.blank?

        generated_short_name = name_value.gsub(/\s+/, "")[0, 12]
        next if generated_short_name.length < 3

        short_name_hash[locale] = generated_short_name
      end

      # Only update if we have a valid short_name to set, otherwise leave as empty hash
      organization.update_column(:short_name, short_name_hash) unless short_name_hash.empty? # rubocop:disable Rails/SkipsModelValidations
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
