# frozen_string_literal: true

require "spec_helper"

describe "Admin publishes component" do
  let(:manifest_name) { "pages" }
  let!(:resource) { create(:page, component:) }

  include_context "when cycling through publication states"
end
