# frozen_string_literal: true

require "spec_helper"

describe "Admin manages meetings attachment collections", type: :system do
  let(:manifest_name) { "meetings" }
  let!(:meeting) { create :meeting, scope: scope, feature: current_feature }

  include_context "when managing a feature as an admin"

  it_behaves_like "manage meetings attachment collections"
end
