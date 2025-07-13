# frozen_string_literal: true

require "spec_helper"

describe "Admin manages initiative component share tokens" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let!(:participatory_space) do
    create(:initiative, organization:)
  end

  it_behaves_like "manage component share tokens" do
    let(:participatory_space_engine) { decidim_admin_initiatives }
  end
end
