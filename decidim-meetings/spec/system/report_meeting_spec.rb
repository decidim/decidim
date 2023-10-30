# frozen_string_literal: true

require "spec_helper"

describe "Report Meeting" do
  include_context "with a component"

  let(:manifest_name) { "meetings" }
  let!(:meetings) { create_list(:meeting, 3, :published, component:) }
  let(:reportable) { meetings.first }
  let(:reportable_path) { resource_locator(reportable).path }
  let!(:user) { create(:user, :confirmed, organization:) }

  let!(:component) do
    create(:meeting_component,
           manifest:,
           participatory_space: participatory_process)
  end

  include_examples "reports"
end
