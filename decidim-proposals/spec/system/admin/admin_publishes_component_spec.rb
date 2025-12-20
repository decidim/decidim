# frozen_string_literal: true

require "spec_helper"

describe "AdminAccess" do
  let(:manifest_name) { "proposals" }
  let!(:proposal) { create(:proposal, :official, component:) }

  include_context "when publishes and unpublishes component"
end
