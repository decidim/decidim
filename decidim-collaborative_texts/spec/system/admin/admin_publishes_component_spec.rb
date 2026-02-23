# frozen_string_literal: true

require "spec_helper"

describe "Admin publishes component" do
  let(:manifest_name) { "collaborative_texts" }
  let!(:resource) { create(:collaborative_text_document, component:) }

  include_context "when publishing and unpublishing the component"
  include_context "when cycling through publication states"
end
