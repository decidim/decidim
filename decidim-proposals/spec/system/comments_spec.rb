# frozen_string_literal: true

require "spec_helper"

describe "Comments", type: :system do
  let!(:component) { create(:proposal_component, organization: organization) }
  let!(:author) { create(:user, :confirmed, organization: organization) }
  let!(:commentable) { create(:proposal, component: component, users: [author]) }

  let(:resource_path) { resource_locator(commentable).path }

  include_examples "comments"
end
