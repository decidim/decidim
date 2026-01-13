# frozen_string_literal: true

require "spec_helper"

describe "Admin publishes component" do
  let(:manifest_name) { "collaborative_texts" }
  let!(:resource) { create(:collaborative_text_document, component:) }

  include_context "when publishes and unpublishes component"
end
