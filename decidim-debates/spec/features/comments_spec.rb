# frozen_string_literal: true

require "spec_helper"

describe "Comments", type: :feature, perform_enqueued: true do
  let!(:feature) { create(:debates_feature, organization: organization) }
  let!(:commentable) { create(:debate, feature: feature) }

  let(:resource_path) { resource_locator(commentable).path }
  include_examples "comments"
end
