class CreateProposalsViews < ActiveRecord::Migration[5.2]
  def change
    create_view :proposals_views, materialized: true
  end
end
