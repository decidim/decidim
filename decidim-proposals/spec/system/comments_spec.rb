# frozen_string_literal: true

require "spec_helper"

describe "Comments" do
  let!(:component) { create(:proposal_component, organization:) }
  let!(:author) { create(:user, :confirmed, organization:) }
  let!(:commentable) { create(:proposal, component:, users: [author]) }
  let!(:organization) { create(:organization) }
  let!(:user) { create(:user, :confirmed, organization:) }
  let!(:comments) { create_list(:comment, 3, commentable:) }

  let(:resource_path) { resource_locator(commentable).path }

  after do
    expect_no_js_errors
  end

  before do
    switch_to_host(organization.host)
  end

  include_examples "comments"

  context "with comments blocked" do
    let!(:component) { create(:proposal_component, participatory_space:, organization:) }
    let(:participatory_space) { create(:participatory_process, :with_steps, organization:) }

    include_examples "comments blocked"
  end
end
