# frozen_string_literal: true

class AddUserToDecidimElectionsVotes < ActiveRecord::Migration[5.2]
  def change
    add_reference :decidim_elections_votes, :decidim_user, null: false
  end
end
