# frozen_string_literal: true

require "spec_helper"

describe "AdminAccess" do
  let(:manifest_name) { "pages" }
  let!(:current_page) { create(:page, component:) }

  include_context "when publishes and unpublishes component"
end
