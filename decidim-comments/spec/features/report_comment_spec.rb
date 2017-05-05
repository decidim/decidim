# frozen_string_literal: true
require "spec_helper"

describe "Report Comment", type: :feature do
  include_context "feature"
  include_examples "reports"

  let(:manifest_name) { "dummy" }
  let!(:commentable) { create(:dummy_resource, feature: feature) }
  let!(:reportable) { create(:comment, commentable: commentable) }
  let(:reportable_path) { decidim_dummy.dummy_resource_path(commentable, feature_id: commentable.feature, participatory_process_id: commentable.feature.participatory_process) }

  let!(:user) { create :user, :confirmed, organization: organization }

  let!(:feature) do
    create(
      :feature,
      manifest: manifest,
      participatory_process: participatory_process
    )
  end
end
