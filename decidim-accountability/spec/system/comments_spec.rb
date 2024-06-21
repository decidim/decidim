# frozen_string_literal: true

require "spec_helper"

describe "Accountability result comments", versioning: true, type: :system do
  let!(:component) { create(:component, manifest_name: :accountability, organization: organization) }
  let!(:commentable) { create(:result, component: component) }

  let(:resource_path) { resource_locator(commentable).path }

  include_examples "comments"

  context "with comments blocked" do
    let!(:component) { create(:component, manifest_name: :accountability, participatory_space:, organization:) }
    let(:participatory_space) { create(:participatory_process, :with_steps, organization:) }

    include_examples "comments blocked"
  end
end
