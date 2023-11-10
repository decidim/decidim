# frozen_string_literal: true

require "spec_helper"

describe "Follow projects" do
  let(:manifest_name) { "budgets" }
  let(:budget) { create(:budget, component:) }

  let!(:followable) do
    create(:project, budget:)
  end

  let(:followable_path) { resource_locator([budget, followable]).path }

  include_examples "follows with a component"
end
