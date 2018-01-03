# This migration comes from decidim (originally 20171013124505)
# frozen_string_literal: true

class AddVerificationAttachmentToAuthorizations < ActiveRecord::Migration[5.1]
  def change
    change_table :decidim_authorizations do |t|
      t.string :verification_attachment
    end
  end
end
