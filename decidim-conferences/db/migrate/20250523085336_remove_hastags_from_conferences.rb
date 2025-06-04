# frozen_string_literal: true

class RemoveHastagsFromConferences < ActiveRecord::Migration[7.0]
  def change
    remove_column :decidim_conferences, :hashtag, :string
  end
end
