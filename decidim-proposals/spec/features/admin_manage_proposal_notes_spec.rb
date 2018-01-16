# frozen_string_literal: true

require "spec_helper"

describe "Admin manage Proposal Notes", type: :feature do
  let(:feature) { create(:proposal_feature) }
  let(:organization) { feature.organization }

  let(:current_user) { create(:user, organization: organization ) }

  let(:manifest_name) { "proposals" }
  let(:proposal) { create(:proposal, feature: feature) }

  let(:proposal_notes_count) { 5 }

  let!(:proposal_notes) do
    create_list(
      :proposal_note,
      proposal_notes_count,
      proposal: proposal,
      author: current_user,
      body: "Awesome note to admin"
    )
  end

  it_behaves_like "manage proposal notes"

end
