# This migration comes from decidim_comments (originally 20171128091519)
class AddUpstreamModerationToComments < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_moderations, :upstream_moderation, :string, default: "unmoderate"
  end
end
