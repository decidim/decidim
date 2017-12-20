class AddPublishedAtValueFromCreatedAtToProposals < ActiveRecord::Migration[5.1]
  def up
    Rake::Task['decidim_proposals:copy_updated_at_to_published_at'].invoke
  end
end
