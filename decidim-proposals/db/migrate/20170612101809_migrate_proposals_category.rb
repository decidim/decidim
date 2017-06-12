# frozen_string_literal: true

class MigrateProposalsCategory < ActiveRecord::Migration[5.1]
  def change
    records = ActiveRecord::Base.connection.execute("SELECT id, decidim_category_id FROM decidim_proposals_proposals")
    now = Time.current
    values = records.to_a.reject!{ |record| record["decidim_category_id"].blank? }.map do |record|
      "(#{record["id"]}, #{record["decidim_category_id"]}, 'Decidim::Proposals::Proposal', '#{now}', '#{now}')"
    end
    if values.any?
      ActiveRecord::Base.connection.execute(
        "INSERT INTO decidim_categorizations(decidim_category_id, categorizable_id, categorizable_type, created_at, updated_at) VALUES #{values.join(', ')}"
      )
    end
    remove_column :decidim_proposals_proposals, :decidim_category_id
  end
end
