# frozen_string_literal: true

require "spec_helper"

describe "Admin publishes component" do
  let(:manifest_name) { "accountability" }
  let!(:result) { create(:result, component:) }

  include_context "when publishes and unpublishes component"
end
