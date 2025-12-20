# frozen_string_literal: true

require "spec_helper"

describe "AdminAccess" do
  let(:manifest_name) { "surveys" }
  let!(:survey) { create(:survey, :published, :clean_after_publish, component:) }

  include_context "when publishes and unpublishes component"
end
