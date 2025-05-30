# frozen_string_literal: true

class RemoveHashtagsFromParticipatoryProcesses < ActiveRecord::Migration[7.0]
  def change
    remove_column :decidim_participatory_processes, :hashtags, :string
  end
end
