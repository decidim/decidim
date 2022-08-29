# frozen_string_literal: true

require "spec_helper"

describe "Space moderator manages global moderations", type: :system do
  let!(:user) do
    create(
      :process_moderator,
      :confirmed,
      organization:,
      participatory_process: participatory_space
    )
  end
  let(:organization) { current_component.organization }
  let(:current_component) { create :component }
  let(:participatory_space) { current_component.participatory_space }
  let!(:reportables) { create_list(:dummy_resource, 2, component: current_component) }
  let(:participatory_space_path) do
    decidim_admin.root_path
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when the user can manage a space that has moderations" do
    it_behaves_like "manage moderations" do
      let(:moderations_link_text) { "Global moderations" }
    end

    it_behaves_like "sorted moderations" do
      let!(:reportables) { create_list(:dummy_resource, 17, component: current_component) }
      let(:moderations_link_text) { "Global moderations" }
    end
  end

  context "when the user can manage a space without moderations" do
    let(:participatory_space) do
      create :participatory_process, organization:
    end

    it "can't see any moderation" do
      visit decidim_admin.moderations_path

      within ".container" do
        expect(page).to have_content("Moderations")

        expect(page).to have_no_selector("table.table-list tbody tr")
      end
    end
  end
end
