# frozen_string_literal: true

require "spec_helper"

describe "Follow proposals" do
  let(:manifest_name) { "proposals" }

  let!(:followable) do
    create(:proposal, component:)
  end

  let(:followable_path) { resource_locator(followable).path }

  include_examples "followable content for users with a component"
end
