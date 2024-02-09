# frozen_string_literal: true

class ChangeColorFieldsOnProposalsStates < ActiveRecord::Migration[6.1]
  def up
    add_column :decidim_proposals_proposal_states, :bg_color, :string, default: "#F3F4F7", null: false
    add_column :decidim_proposals_proposal_states, :text_color, :string, default: "#3E4C5C", null: false
    remove_column :decidim_proposals_proposal_states, :css_class

    Decidim::Proposals::ProposalState.reset_column_information

    # rubocop:disable Rails/SkipsModelValidations
    Decidim::Proposals::ProposalState.where(token: :accepted).update_all(bg_color: "#c4ecd0", text_color: "#16592e")
    Decidim::Proposals::ProposalState.where(token: :evaluating).update_all(bg_color: "#ffeebd", text_color: "#ad4910")
    Decidim::Proposals::ProposalState.where(token: :rejected).update_all(bg_color: "#ffdee3", text_color: "#b9081b")
    # rubocop:enable Rails/SkipsModelValidations
  end

  def down
    remove_column :decidim_proposals_proposal_states, :bg_color
    remove_column :decidim_proposals_proposal_states, :text_color
    add_column :decidim_proposals_proposal_states, :css_class, :string
  end
end
