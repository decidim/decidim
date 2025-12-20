# frozen_string_literal: true

require "spec_helper"

describe "AdminAccess" do
  let(:manifest_name) { "collaborative_texts" }
  let!(:collaborative_text_document) { create(:collaborative_text_document, component:) }

  include_context "when publishes and unpublishes component"
end
