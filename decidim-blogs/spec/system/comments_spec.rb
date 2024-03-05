# frozen_string_literal: true

require "spec_helper"

describe "Comments", perform_enqueued: true do
  let!(:component) { create(:post_component, organization:) }
  let!(:commentable) { create(:post, component:) }

  let(:resource_path) { resource_locator(commentable).path }

  include_examples "comments"

  context "with comments blocked" do
    let!(:component) { create(:post_component, participatory_space:, organization:) }
    let(:participatory_space) { create(:participatory_process, :with_steps, organization:) }

    include_examples "comments blocked"
  end
end
