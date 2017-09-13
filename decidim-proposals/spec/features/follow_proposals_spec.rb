# frozen_string_literal: true

require "spec_helper"

describe "Follow proposals", type: :feature do
  let(:manifest_name) { "proposals" }

  let!(:followable) do
    create(:proposal, feature: feature)
  end

  include_examples "follows"
end
