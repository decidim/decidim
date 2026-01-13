# frozen_string_literal: true

require "spec_helper"

describe "Admin publishes component" do
  let(:manifest_name) { "meetings" }
  let!(:resource) { create(:meeting, :published, component:) }

  include_context "when publishes and unpublishes component"
end
