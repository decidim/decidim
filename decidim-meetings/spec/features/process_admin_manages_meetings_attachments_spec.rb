# frozen_string_literal: true

require "spec_helper"

describe "Process admin manages meetings attachments", type: :feature do
  let(:manifest_name) { "meetings" }
  let!(:meeting) { create :meeting, scope: scope, feature: current_feature }

  include_context "feature process admin"

  it_behaves_like "manage meetings attachments"
end
