# frozen_string_literal: true

require "spec_helper"

describe "Admin manages initiative share tokens" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let!(:participatory_space) do
    create(:initiative, organization:)
  end

  it_behaves_like "manage participatory space share tokens" do
    let(:participatory_space_path) { decidim_admin_initiatives.edit_initiative_path(participatory_space) }
    let(:participatory_spaces_path) { decidim_admin_initiatives.initiatives_path }
  end
end
