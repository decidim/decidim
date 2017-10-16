# frozen_string_literal: true

require "spec_helper"

describe "Accountability result comments", type: :feature, perform_enqueued: true do
  let!(:feature) { create(:feature, manifest_name: :accountability, organization: organization) }
  let!(:commentable) { create(:result, feature: feature) }

  let(:resource_path) { resource_locator(commentable).path }
  include_examples "comments"
end
