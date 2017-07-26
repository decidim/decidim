# frozen_string_literal: true

require "spec_helper"

describe "Comments", type: :feature, perform_enqueued: true do
  let!(:feature) { create(:budget_feature, organization: organization) }
  let!(:commentable) { create(:project, feature: feature) }

  let(:resource_path) { resource_locator(commentable).path }
  include_examples "comments"
end
