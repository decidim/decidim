class AddReportableFieldsToComments < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_comments_comments, :report_count, :integer, null: false, default: 0
    add_column :decidim_comments_comments, :hidden_at, :datetime
  end
end
