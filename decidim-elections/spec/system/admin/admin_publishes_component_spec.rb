# frozen_string_literal: true

require "spec_helper"

describe "Admin publishes component" do
  let(:manifest_name) { "elections" }
  let!(:resource) { create(:election, :with_token_csv_census, :published, component:) }

  include_context "when publishing and unpublishing the component"
  include_context "when cycling through publication states"
end
