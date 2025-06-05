# frozen_string_literal: true

class RemoveHashtagFromParticipatoryProcessesGroups < ActiveRecord::Migration[7.1]
  def change
    remove_column :decidim_participatory_process_groups, :hashtag, :string
  end
end
