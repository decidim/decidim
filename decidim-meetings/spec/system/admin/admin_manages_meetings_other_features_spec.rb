# frozen_string_literal: true

require "spec_helper"

describe "Admin manages meetings other features", serves_geocoding_autocomplete: true, serves_map: true, type: :system do
  let(:manifest_name) { "meetings" }
  let!(:meeting) { create(:meeting, :published, scope:, services: [], component: current_component) }

  include_context "when managing a component as an admin"

  it_behaves_like "manage registrations"
  it_behaves_like "manage announcements"
  it_behaves_like "manage agenda"
  it_behaves_like "manage invites"
  it_behaves_like "export meetings"
  it_behaves_like "duplicate meetings"
end
