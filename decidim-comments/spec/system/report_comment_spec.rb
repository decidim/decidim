# frozen_string_literal: true

require "spec_helper"

describe "Report Comment", type: :system do
  include_context "with a feature"

  let(:manifest_name) { "dummy" }
  let!(:commentable) { create(:dummy_resource, feature: feature) }
  let!(:reportable) { create(:comment, commentable: commentable) }
  let(:reportable_path) { resource_locator(commentable).path }

  let!(:user) { create :user, :confirmed, organization: organization }

  let!(:feature) do
    create(
      :feature,
      manifest: manifest,
      participatory_space: participatory_process
    )
  end

  include_examples "reports"
end
