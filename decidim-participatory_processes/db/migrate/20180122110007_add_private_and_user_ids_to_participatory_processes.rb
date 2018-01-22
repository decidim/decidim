# frozen_string_literal: true

class AddPrivateAndUserIdsToParticipatoryProcesses < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_participatory_processes, :private_process, :boolean, default: false

    create_table :decidim_participatory_process_users do |t|
      t.references :decidim_participatory_process, index: { name: "index_decidim_processes_users_on_decidim_process_id" }
      t.references :decidim_user, index: { name: "index_decidim_processes_users_on_decidim_user_id" }
    end
  end
end
