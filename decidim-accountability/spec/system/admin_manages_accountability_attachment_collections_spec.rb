# frozen_string_literal: true

require "spec_helper"

describe "Admin manages accountability attachment collections", type: :system do
  include_context "with a component"
  let(:manifest_name) { "accountability" }
  let!(:result) { create :result, component: current_component }

  include_context "when managing a component as an admin"

  it_behaves_like "manage accountability attachment collections"
end
