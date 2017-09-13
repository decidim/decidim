# frozen_string_literal: true

require "spec_helper"

describe "Follow meetings", type: :feature do
  let(:manifest_name) { "meetings" }

  let!(:followable) do
    create(:meeting, feature: feature)
  end

  include_examples "follows"
end
