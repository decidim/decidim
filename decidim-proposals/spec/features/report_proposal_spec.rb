# frozen_string_literal: true

require "spec_helper"

describe "Report Proposal", type: :feature do
  include_context "with a feature"

  let(:manifest_name) { "proposals" }
  let!(:proposals) { create_list(:proposal, 3, feature: feature) }
  let(:reportable) { proposals.first }
  let(:reportable_path) { resource_locator(reportable).path }
  let!(:user) { create :user, :confirmed, organization: organization }

  let!(:feature) do
    create(:proposal_feature,
           manifest: manifest,
           participatory_space: participatory_process)
  end

  include_examples "reports"
end
