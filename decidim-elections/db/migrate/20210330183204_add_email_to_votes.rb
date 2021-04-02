# frozen_string_literal: true

class AddEmailToVotes < ActiveRecord::Migration[5.2]
  def change
    change_table :decidim_elections_votes, bulk: true do |t|
      t.string :email
      t.change :decidim_user_id, :bigint, null: true
    end
  end
end
