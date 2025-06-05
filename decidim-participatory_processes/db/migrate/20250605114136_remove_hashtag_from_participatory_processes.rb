# frozen_string_literal: true

class RemoveHashtagFromParticipatoryProcesses < ActiveRecord::Migration[7.1]
  def change
    remove_column :decidim_participatory_processes, :hashtag, :string
  end
end
