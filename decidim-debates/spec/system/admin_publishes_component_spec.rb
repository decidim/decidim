# frozen_string_literal: true

require "spec_helper"

describe "Admin publishes component" do
  let(:manifest_name) { "debates" }
  let!(:resource) { create(:debate, component:) }

  include_context "when publishes and unpublishes component"
end
