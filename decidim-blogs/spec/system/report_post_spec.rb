# frozen_string_literal: true

require "spec_helper"

describe "Report a post", type: :system do
  include_context "with a component"

  let(:manifest_name) { "blogs" }
  let!(:posts) { create_list(:post, 3, component: component) }
  let(:reportable) { posts.first }
  let(:reportable_path) { resource_locator(reportable).path }
  let!(:user) { create(:user, :confirmed, organization: organization) }

  let!(:component) do
    create(:post_component,
           manifest: manifest,
           participatory_space: participatory_process)
  end

  include_examples "reports"
end
