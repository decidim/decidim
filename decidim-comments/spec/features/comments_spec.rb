# frozen_string_literal: true

require "spec_helper"

describe "Comments", type: :feature, perform_enqueued: true do
  let!(:feature) { create(:feature, manifest_name: :dummy, organization: organization) }
  let!(:author) { create(:user, :confirmed, organization: organization) }
  let!(:commentable) { create(:dummy_resource, feature: feature, author: author) }

  let(:resource_path) { resource_locator(commentable).path }
  include_examples "comments"
end
