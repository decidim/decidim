# frozen_string_literal: true

require "spec_helper"

describe "AdminAccess" do
  let(:manifest_name) { "meetings" }
  let!(:meeting) { create(:meeting, scope:, component: current_component) }

  include_context "when publishes and unpublishes component"
end
