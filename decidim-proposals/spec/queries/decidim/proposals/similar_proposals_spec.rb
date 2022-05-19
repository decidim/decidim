# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::SimilarProposals do
  let(:organization) { create(:organization, enable_machine_translations: enabled) }
  let(:participatory_process) { create(:participatory_process, organization: organization) }
  let(:component) { create(:proposal_component, participatory_space: participatory_process) }

  let!(:proposal) { create(:proposal, component: component, body: proposal_body, title: proposal_title) }
  let!(:matching_proposal) { create(:proposal, component: component, body: matching_body, title: matching_title) }
  let!(:missed_proposal) { create(:proposal, component: component, body: missing_body, title: missing_title) }

  context "when machine_translations is disabled" do
    let(:enabled) { false }
    let(:proposal_body) { "100% match for body" }
    let(:proposal_title) { "100% match for title" }
    let(:matching_body) { proposal_body }
    let(:matching_title) { proposal_title }
    let(:missing_body) { "Some Random body" }
    let(:missing_title) { "Some random title" }

    it "finds the similar proposal" do
      Decidim::Proposals.similarity_threshold = 0.85
      expect(described_class.for([component], proposal).map(&:id).sort).to eq([proposal.id, matching_proposal.id])
    end

    it "counts just the available proposals" do
      Decidim::Proposals.similarity_threshold = 0.85
      expect(described_class.for([component], proposal).size).to eq(2)
    end
  end

  context "when machine_translations is enabled" do
    let(:enabled) { true }
    let(:proposal_body) { { en: "100% match for body" } }
    let(:proposal_title) { { en: "100% match for title" } }
    let(:matching_body) { missing_body.merge({ machine_translations: proposal_body }) }
    let(:matching_title) { missing_title.merge({ machine_translations: proposal_title }) }
    let(:missing_body) { { ro: "Some Random body" } }
    let(:missing_title) { { ro: "Some random title" } }

    it "finds the similar proposal" do
      Decidim::Proposals.similarity_threshold = 0.85
      I18n.with_locale(:en) do
        expect(described_class.for([component], proposal).map(&:id).sort).to eq([proposal.id, matching_proposal.id])
      end
    end

    it "counts just the available proposals" do
      Decidim::Proposals.similarity_threshold = 0.85
      I18n.with_locale(:en) do
        expect(described_class.for([component], proposal).size).to eq(2)
      end
    end
  end
end
