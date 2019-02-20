# frozen_string_literal: true

class UseMd5Indexes < ActiveRecord::Migration[5.2]
  def up
    remove_index :decidim_proposals_proposals, name: "decidim_proposals_proposal_title_search"
    remove_index :decidim_proposals_proposals, name: "decidim_proposals_proposal_body_search"
    execute "CREATE INDEX decidim_proposals_proposal_title_search ON decidim_proposals_proposals(md5(title::text))"
    execute "CREATE INDEX decidim_proposals_proposal_body_search ON decidim_proposals_proposals(md5(body::text))"
  end

  def down
    remove_index :decidim_proposals_proposals, name: "decidim_proposals_proposal_title_search"
    remove_index :decidim_proposals_proposals, name: "decidim_proposals_proposal_body_search"
    add_index :decidim_proposals_proposals, :title, name: "decidim_proposals_proposal_title_search"
    add_index :decidim_proposals_proposals, :body, name: "decidim_proposals_proposal_body_search"
  end
end
