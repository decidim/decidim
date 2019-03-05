# frozen_string_literal: true

class AddEncryptedMetadataToDecidimInitiativesVotes < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_initiatives_votes, :encrypted_metadata, :text
  end
end
