# frozen_string_literal: true

class AddAttachmentsEnabledOption < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_initiatives_types, :attachments_enabled, :boolean, null: false, default: false
  end
end
