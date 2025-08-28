# frozen_string_literal: true

require "spec_helper"

describe "Comments", perform_enqueued: true do
  let!(:component) { create(:debates_component, organization:) }
  let!(:commentable) { create(:debate, :ongoing_ama, component:) }

  let(:resource_path) { resource_locator(commentable).path }

  include_examples "comments"

  context "with comments blocked" do
    let!(:component) { create(:debates_component, participatory_space:, organization:) }
    let(:participatory_space) { create(:participatory_process, :with_steps, organization:) }

    include_examples "comments blocked"
  end

  context "with two columns layout" do
    let!(:commentable) { create(:debate, :ongoing_ama, component:, comments_layout: :two_columns) }
    let!(:closed_commentable) { create(:debate, :closed, component:, comments_layout: :two_columns) }

    include_examples "comments with two columns"
  end
end
