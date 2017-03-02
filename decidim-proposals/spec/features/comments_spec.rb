# frozen_string_literal: true
require "spec_helper"

describe "Comments", type: :feature do
  let!(:feature) { create(:proposal_feature, organization: organization) }
  let!(:commentable) { create(:proposal, feature: feature) }

  let(:resource_path) { decidim_proposals.proposal_path(commentable, feature_id: feature, participatory_process_id: feature.participatory_process) }
  include_examples "comments"
end
