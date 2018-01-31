# frozen_string_literal: true

class CreateParticipatoryProcessPrivateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_participatory_process_private_users do |t|
      t.references :decidim_user, index: { name: "index_decidim_processes_users_on_decidim_user_id" }
      t.references :decidim_participatory_process, index: { name: "index_decidim_processes_users_on_decidim_process_id" }

      t.timestamps
    end
  end
end
