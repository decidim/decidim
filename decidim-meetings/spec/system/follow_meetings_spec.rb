# frozen_string_literal: true

require "spec_helper"

describe "Follow meetings", type: :system do
  let(:manifest_name) { "meetings" }

  let!(:followable) do
    create(:meeting, :published, component:)
  end

  let(:followable_path) { resource_locator(followable).path }

  include_examples "follows"
end
