# frozen_string_literal: true

require "spec_helper"

describe "Comments", type: :system do
  let!(:component) { create(:budgets_component, organization: organization) }
  let!(:budget) { create(:budget, component: component) }
  let!(:commentable) { create(:project, budget: budget) }

  let(:resource_path) { resource_locator([budget, commentable]).path }

  include_examples "comments"
end
