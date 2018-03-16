# frozen_string_literal: true

require "spec_helper"

describe "Process admin manages meetings attachments", type: :system, serves_map: true do
  let(:manifest_name) { "meetings" }
  let!(:meeting) { create :meeting, scope: scope, component: current_component }

  include_context "when managing a component as a process admin"

  it_behaves_like "manage meetings attachments"
end
