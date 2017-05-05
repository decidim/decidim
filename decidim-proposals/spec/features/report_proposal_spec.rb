# frozen_string_literal: true
require "spec_helper"

describe "Report Proposal", type: :feature do
  include_context "feature"
  include_examples "reports"

  let(:manifest_name) { "proposals" }
  let!(:proposals) { create_list(:proposal, 3, feature: feature) }
  let(:reportable) { proposals.first }
  let(:reportable_path) { decidim_proposals.proposal_path(reportable, feature_id: feature, participatory_process_id: feature.participatory_process) }
  let!(:user) { create :user, :confirmed, organization: organization }

  let!(:feature) do
    create(:proposal_feature,
           manifest: manifest,
           participatory_process: participatory_process)
  end
end
