# frozen_string_literal: true
require "spec_helper"

describe "Comments", type: :feature do
  let!(:feature) { create(:feature, manifest_name: :dummy, organization: organization) }
  let!(:commentable) { create(:dummy_resource, feature: feature) }

  let(:resource_path) { decidim_dummy.dummy_resource_path(commentable, feature_id: commentable.feature, participatory_process_id: commentable.feature.participatory_process) }
  include_examples "comments"
end
