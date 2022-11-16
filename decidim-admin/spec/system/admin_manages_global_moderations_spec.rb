# frozen_string_literal: true

require "spec_helper"

describe "Admin manages global moderations", type: :system do
  let!(:user) do
    create(
      :user,
      :confirmed,
      :admin,
      organization:
    )
  end
  let(:organization) { current_component.organization }
  let(:current_component) { create :component }
  let!(:reportables) { create_list(:dummy_resource, 2, component: current_component) }
  let(:participatory_space_path) do
    decidim_admin.moderations_path
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when displaying the counter" do
    let!(:reported_user) { create(:user, :confirmed, organization:) }
    let!(:moderation) { create(:user_moderation, user: reported_user, report_count: 1) }
    let!(:reportables) { create(:user_report, moderation:, user:, reason: "spam") }

    context "when displaying the user counter" do
      it "can not see user menu counter for resources" do
        visit decidim_admin.moderations_path

        within ".secondary-nav" do
          within ".is-active" do
            expect(page).to have_css("span.component-counter--off", visible: :visible)
            expect(page).to have_css("span", text: "0")
          end
        end
      end

      it "can see user menu counter" do
        visit decidim_admin.moderations_path

        within ".secondary-nav" do
          expect(page).to have_css("span.component-counter", visible: :visible, count: 2)
          expect(page).to have_css("span", text: "1")
        end
      end
    end
  end

  it "can see menu counter" do
    visit decidim_admin.moderations_path

    within ".secondary-nav" do
      within ".is-active" do
        expect(page).to have_css("span.component-counter", visible: :visible)
      end
    end
  end

  it_behaves_like "manage moderations" do
    let(:moderations_link_text) { "Global moderations" }
  end

  it_behaves_like "sorted moderations" do
    let!(:reportables) { create_list(:dummy_resource, 17, component: current_component) }
    let(:moderations_link_text) { "Global moderations" }
  end
end
