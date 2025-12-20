# frozen_string_literal: true

require "spec_helper"

describe "AdminAccess" do
  let(:manifest_name) { "blogs" }
  let!(:post) { create(:post, component:) }

  include_context "when publishes and unpublishes component"
end
