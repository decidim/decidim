# frozen_string_literal: true

require "spec_helper"

describe "Admin publishes component" do
  let(:manifest_name) { "surveys" }
  let!(:resource) { create(:survey, :published, :clean_after_publish, component:) }

  include_context "when cycling through publication states"
end
