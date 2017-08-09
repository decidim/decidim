# frozen_string_literal: true

require "spec_helper"

describe "Admin manages meetings", type: :feature, serves_map: true do
  let(:manifest_name) { "meetings" }
  let!(:meeting) { create :meeting, scope: scope, feature: current_feature }

  include_context "feature admin"

  it_behaves_like "manage meetings"
  it_behaves_like "manage announcements"
end
