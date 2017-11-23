class AddUpstreamModerationToComments < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_comments_comments, :upstream_moderation, :string, default: "unmoderate"
  end
end
