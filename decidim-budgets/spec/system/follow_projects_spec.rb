# frozen_string_literal: true

require "spec_helper"

describe "Follow projects", type: :system do
  let(:manifest_name) { "budgets" }

  let!(:followable) do
    create(:project, component: component)
  end

  include_examples "follows"
end
