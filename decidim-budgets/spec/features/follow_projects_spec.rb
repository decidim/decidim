# frozen_string_literal: true

require "spec_helper"

describe "Follow projects", type: :feature do
  let(:manifest_name) { "budgets" }

  let!(:followable) do
    create(:project, feature: feature)
  end

  include_examples "follows"
end
