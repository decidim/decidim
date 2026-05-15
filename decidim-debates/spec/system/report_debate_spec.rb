# frozen_string_literal: true

require "spec_helper"

describe "Report a debate" do
  include_context "with a component"

  let(:manifest_name) { "debates" }
  let!(:debates) { create_list(:debate, 3, :participant_author, component:) }
  let(:reportable) { debates.first }
  let(:reportable_path) { resource_locator(reportable).path }
  let(:reportable_index_path) { resource_locator(reportable).index }

  let!(:component) do
    create(:debates_component,
           manifest:,
           participatory_space: participatory_process)
  end

  include_examples "reports by user type"
end
