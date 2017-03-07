class CreateReports < ActiveRecord::Migration[5.0]
  def change
    create_table :decidim_reports do |t|
      t.references :decidim_reportable, null: false, polymorphic: true, index: { name: "decidim_reports_reportable" }
      t.references :decidim_user, null: false, index: { name: "decidim_reports_user" }
      t.string :reason, null: false
      t.text :details

      t.timestamps
    end

    add_index :decidim_reports, [:decidim_reportable_id, :decidim_user_id], unique: true, name: "decidim_reports_reportable_user_unique"
  end
end
