# frozen_string_literal: true

class RemoveHashtagsFromParticipatoryProcessGroups < ActiveRecord::Migration[7.0]
  def change
    remove_column :decidim_participatory_process_groups, :hashtag, :string
  end
end
