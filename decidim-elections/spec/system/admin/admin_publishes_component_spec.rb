# frozen_string_literal: true

require "spec_helper"

describe "AdminAccess" do
  let(:manifest_name) { "elections" }
  let!(:election) { create(:election, :with_token_csv_census, :published, component:) }

  include_context "when publishes and unpublishes component"
end
