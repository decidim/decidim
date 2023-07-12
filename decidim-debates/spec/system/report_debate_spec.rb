# frozen_string_literal: true

# Redesign pending
# These specs are pending for the new design to be applied to proposals module
# The failure happens in the report modal, which is not yet implemented
#
require "spec_helper"

describe "Report a debate", type: :system do
  include_context "with a component"

  let(:manifest_name) { "debates" }
  let!(:debates) { create_list(:debate, 3, :participant_author, component:) }
  let(:reportable) { debates.first }
  let(:reportable_path) { resource_locator(reportable).path }

  let!(:component) do
    create(:debates_component,
           manifest:,
           participatory_space: participatory_process)
  end

  include_examples "reports by user type"
end
