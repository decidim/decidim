# frozen_string_literal: true

require "spec_helper"

describe "Report a post" do
  include_context "with a component"

  let(:manifest_name) { "blogs" }
  let(:reportable) { create(:post, component:) }
  let(:reportable_path) { resource_locator(reportable).path }
  let(:reportable_index_path) { resource_locator(reportable).index }
  let!(:user) { create(:user, :confirmed, organization:) }

  let!(:component) { create(:post_component, manifest:, participatory_space: participatory_process) }

  include_examples "reports by user type"
end
