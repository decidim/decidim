# frozen_string_literal: true

require "spec_helper"

describe "Follow results", type: :feature do
  let(:manifest_name) { "results" }

  let!(:followable) do
    create(:result, feature: feature)
  end

  include_examples "follows"
end
