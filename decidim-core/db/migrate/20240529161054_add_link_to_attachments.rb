# frozen_string_literal: true

class AddLinkToAttachments < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_attachments, :link, :string
  end
end
