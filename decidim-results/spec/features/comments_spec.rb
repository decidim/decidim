# frozen_string_literal: true

require "spec_helper"

describe "Comments", type: :feature, perform_enqueued: true do
  let!(:feature) { create(:result_feature, organization: organization) }
  let!(:commentable) { create(:result, feature: feature) }

  let(:resource_path) { decidim_results.result_path(commentable, feature_id: feature, participatory_process_id: feature.participatory_process) }
  include_examples "comments"
end
