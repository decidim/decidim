# frozen_string_literal: true

require "spec_helper"

describe "Comments", perform_enqueued: true do
  let!(:component) { create(:post_component, organization: organization) }
  let!(:commentable) { create(:post, component: component) }

  let(:resource_path) { resource_locator(commentable).path }

  include_examples "comments"

  context "with comments blocked" do
    let!(:component) { create(:post_component, participatory_space: participatory_space, organization: organization) }
    let(:participatory_space) { create(:participatory_process, :with_steps, organization: organization) }

    include_examples "comments blocked"
  end
end
