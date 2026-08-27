# frozen_string_literal: true

class GenerateAvifVariants < ActiveRecord::Migration[8.1]
  class Organization < ApplicationRecord
    self.table_name = "decidim_organizations"
  end

  def up
    Decidim::UserBaseEntity.find_each do |user|
      next unless user.attached_uploader(:avatar).attached?

      Decidim::AvatarUploader.variants.each_key do |variant_key|
        Decidim::GenerateAvifVariantJob.perform_later("Decidim::UserBaseEntity", user.id, :avatar, variant_key)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
