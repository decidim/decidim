# frozen_string_literal: true

require "spec_helper"

describe "Follow meetings", type: :system do
  let(:manifest_name) { "meetings" }

  let!(:followable) do
    create(:meeting, component: component)
  end

  include_examples "follows"
end
