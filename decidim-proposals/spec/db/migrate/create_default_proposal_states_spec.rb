# frozen_string_literal: true

require "spec_helper"
require_relative "../../../db/migrate/20240110203504_create_default_proposal_states"

describe "CreateDefaultProposalStates", type: :migration do
  let(:migration) { CreateDefaultProposalStates.new }
  let(:organization) { create(:organization) }
  let(:component) { create(:proposal_component, organization:) }
  let(:admin_user) { create(:user, :admin, organization:) }

  # A later migration renames this table, so recreate it for the duration of the test.
  before do
    ActiveRecord::Base.connection.create_table(:decidim_proposals_proposal_states) do |t|
      t.jsonb :title
      t.jsonb :announcement_title
      t.string :token, null: false
      t.references :decidim_component, index: true, null: false
      t.integer :proposals_count, default: 0, null: false
      t.string :bg_color, default: "#F6F8FA", null: false
      t.string :text_color, default: "#4B5058", null: false
    end
    Decidim::Proposals::ProposalState.reset_column_information
  end

  after do
    ActiveRecord::Base.connection.drop_table(:decidim_proposals_proposal_states, if_exists: true)
  end

  it "defines the legacy model it needs pointing to the pre-rename table" do
    expect(Decidim::Proposals::ProposalState.table_name).to eq("decidim_proposals_proposal_states")
  end

  describe "Decidim::Proposals.create_default_states!" do
    it "creates the default states through the legacy model" do
      states = Decidim::Proposals.create_default_states!(component, admin_user)

      expect(states.keys).to contain_exactly(:evaluating, :accepted, :rejected)
      expect(Decidim::Proposals::ProposalState.where(decidim_component_id: component.id).pluck(:token))
        .to contain_exactly("evaluating", "accepted", "rejected")
    end
  end
end
