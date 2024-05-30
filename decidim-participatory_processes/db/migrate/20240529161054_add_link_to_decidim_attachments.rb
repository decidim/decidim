# frozen_string_literal: true

class AddLinkToDecidimAttachments < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_attachments, :link, :string
  end
end
