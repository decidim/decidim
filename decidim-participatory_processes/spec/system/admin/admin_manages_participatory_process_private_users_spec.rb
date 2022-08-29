# frozen_string_literal: true

require "spec_helper"

describe "Admin manages participatory process private users", type: :system do
  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:organization) { create(:organization) }
  let!(:participatory_process) { create(:participatory_process, organization:, private_space: true) }

  it_behaves_like "manage participatory process private users examples"
end
