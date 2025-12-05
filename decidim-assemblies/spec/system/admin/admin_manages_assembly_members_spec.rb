# frozen_string_literal: true

require "spec_helper"

describe "Admin manages assembly members" do
  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:organization) { create(:organization) }
  let!(:assembly) { create(:assembly, organization:, private_space: true) }

  it_behaves_like "manage assembly members examples"
end
