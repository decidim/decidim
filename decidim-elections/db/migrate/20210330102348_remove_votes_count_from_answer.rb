# frozen_string_literal: true

class RemoveVotesCountFromAnswer < ActiveRecord::Migration[5.2]
  def change
    remove_column :decidim_elections_answers, :votes_count, :integer
  end
end
