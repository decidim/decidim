# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::HideAllCreatedByAuthorJob do
  subject { described_class }

  context "when proposal" do
    it_behaves_like "has hideable resource" do
      let(:component) { create(:proposal_component, organization:) }
      let(:hideable) { create(:proposal, component:, users: [author]) }
      let(:not_hideable) { create(:proposal, component:) }
    end
  end

  context "when collaborative_draft" do
    it_behaves_like "has hideable resource" do
      let(:component) { create(:proposal_component, :with_collaborative_drafts_enabled, organization:) }
      let(:hideable) { create(:collaborative_draft, component:, users: [author]) }
      let(:not_hideable) { create(:collaborative_draft, component:) }
    end
  end
end
