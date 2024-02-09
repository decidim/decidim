# frozen_string_literal: true

class ChangeColorFieldsOnProposalsStates < ActiveRecord::Migration[6.1]
  def up
    add_column :decidim_proposals_proposal_states, :bg_color, :string, default: "#000000", null: false
    add_column :decidim_proposals_proposal_states, :text_color, :string, default: "#ffffff", null: false
    remove_column :decidim_proposals_proposal_states, :css_class
  end

  def down
    remove_column :decidim_proposals_proposal_states, :bg_color
    remove_column :decidim_proposals_proposal_states, :text_color
    add_column :decidim_proposals_proposal_states, :css_class, :string
  end
end
