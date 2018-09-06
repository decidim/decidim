# frozen_string_literal: true

require "spec_helper"

describe "Report Debate", type: :system do
  include_context "with a component"

  let(:manifest_name) { "debates" }
  let!(:debates) { create_list(:debate, 3, :with_author, component: component) }
  let(:reportable) { debates.first }
  let(:reportable_path) { resource_locator(reportable).path }
  let!(:user) { create :user, :confirmed, organization: organization }

  let!(:component) do
    create(:debates_component,
           manifest: manifest,
           participatory_space: participatory_process)
  end

  include_examples "reports"
end
