# frozen_string_literal: true

require "spec_helper"

describe "Comments", type: :system do
  let!(:component) { create(:budget_component, organization: organization) }
  let!(:commentable) { create(:project, component: component) }

  let(:resource_path) { resource_locator(commentable).path }

  include_examples "comments"
end
