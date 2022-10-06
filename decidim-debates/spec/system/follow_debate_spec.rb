# frozen_string_literal: true

require "spec_helper"

describe "Follow debates", type: :system do
  let(:manifest_name) { "debates" }

  let!(:followable) do
    create(:debate, component:)
  end

  let(:followable_path) { resource_locator(followable).path }

  include_examples "follows"
end
