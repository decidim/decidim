# frozen_string_literal: true

require "spec_helper"
require "decidim/proposals/test/factories"

describe "Question", type: :system do
  let(:manifest) { Decidim.find_component_manifest("proposals") }
  let(:organization) { create(:organization) }
  let(:consultation) { create(:consultation, :published, organization:) }
  let(:question) { create(:question, consultation:) }
  let(:component) do
    create(:component,
           manifest:,
           participatory_space: question)
  end
  let!(:proposal) { create(:proposal, component:) }

  context "when there is a proposal component" do
    before do
      switch_to_host(organization.host)
      visit decidim_consultations.decidim_question_proposals_path(question_slug: question.slug, component_id: component)
    end

    it "finds the proposal" do
      expect(page).to have_content translated(proposal.title)
    end
  end
end
