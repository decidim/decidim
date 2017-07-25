class CreateImpersonationLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_admin_impersonation_logs do |t|
      t.references :decidim_admin, index: true
      t.references :decidim_user, index: true
      t.datetime :start_at
      t.datetime :end_at

      t.timestamps
    end
  end
end
