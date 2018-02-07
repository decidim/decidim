# frozen_string_literal: true

RSpec.shared_context "when in a proposal" do
  routes { Decidim::Proposals::Engine.routes }

  let(:proposal) { create(:proposal, feature: feature) }
  let(:user) { create(:user, :confirmed, organization: feature.organization) }
  let(:params) do
    {
      proposal_id: proposal.id,
      feature_id: feature.id,
      participatory_process_slug: feature.participatory_space.slug
    }
  end

  before do
    request.env["decidim.current_organization"] = feature.organization
    request.env["decidim.current_feature"] = feature
    request.env["decidim.current_participatory_space"] = feature.participatory_space
    sign_in user
  end
end
