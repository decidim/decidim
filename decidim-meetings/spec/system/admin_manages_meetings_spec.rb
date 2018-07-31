# frozen_string_literal: true

require "spec_helper"

describe "Admin manages meetings", type: :system, serves_map: true do
  let(:manifest_name) { "meetings" }
  let!(:meeting) { create :meeting, scope: scope, services: [], component: current_component }

  include_context "when managing a component as an admin"

  it_behaves_like "manage meetings"
  it_behaves_like "manage registrations"
  it_behaves_like "manage announcements"
  it_behaves_like "manage agenda"
  it_behaves_like "manage minutes"
  it_behaves_like "manage invites"
end
