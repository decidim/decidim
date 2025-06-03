# frozen_string_literal: true

require "spec_helper"

describe "Explore API credentials" do
  let(:admin) { create(:admin) }
  let!(:organization) { create(:organization) }
  let!(:organization1) { create(:organization) }
  let(:dummy_token) { "token1234567890" }

  before do
    allow(Rails.application.secrets).to receive(:dig).with(:decidim, :api, :jwt_secret).and_return("mocked_secret")
    allow(SecureRandom).to receive(:alphanumeric).and_return(dummy_token)
    login_as admin, scope: :admin
    visit decidim_system.admins_path
  end

  it "API credentials index" do
    within "nav.main-nav" do
      expect(page).to have_link("API credentials", href: "/system/api_users")
      click_link_or_button "API credentials"
      li_element = find("li.active")
      within li_element do
        expect(page).to have_link("API credentials", href: "/system/api_users")
      end
    end
    expect(page).to have_current_path("/system/api_users")
    within "table.stack" do
      header_cells = find_all("th")
      expect(header_cells[0]).to have_content("Organization")
      expect(header_cells[1]).to have_content("Name")
      expect(header_cells[2]).to have_content("Key")
      expect(header_cells[3]).to have_content("Secret")
      expect(header_cells[4]).to have_content("Created at")
      expect(header_cells[5]).to have_content("Actions")
    end
  end

  context "with api_users" do
    let!(:set) { create_list(:api_user, 3, organization: organization) }
    let!(:set1) { create_list(:api_user, 4, organization: organization1) }

    before do
      visit decidim_system.api_users_path
    end

    it "shows all of the api_users" do
      api_users = Decidim::Api::ApiUser.all

      within "table.stack" do
        api_users.each do |user|
          tr = find("td", text: user.api_key).find(:xpath, "..")
          row_cells = tr.find_all("td")
          expect(row_cells.first).to have_content(user.organization.host)
          expect(row_cells[1]).to have_content(user.name)
          expect(row_cells[2]).to have_content(user.api_key)
          expect(row_cells.last).to have_link("Remove user")
          expect(row_cells.last).to have_link("Refresh secret")
        end
      end
      expect(page).to have_link("New API user")
    end

    it "removes the api user" do
      deleting_user = set.last
      expect(page).to have_content(deleting_user.api_key)
      within "table.stack" do
        delete_tr = find("td", text: deleting_user.api_key).find(:xpath, "..")
        within delete_tr do
          click_link_or_button "Remove user"
        end
      end
      expect(page).to have_content("Are you sure you want to remove this API user?")
      click_link_or_button "OK"
      expect(page).to have_content("API user successfully deleted.")
      expect(page).to have_current_path("/system/api_users")
      expect(Decidim::Api::ApiUser.count).to eq(6)
      expect(page).to have_no_content(deleting_user.api_key)
    end

    it "refreshes the secret" do
      refreshing_user = set.last
      refreshing_tr = find("td", text: refreshing_user.api_key).find(:xpath, "..")

      within refreshing_tr do
        click_link_or_button "Refresh secret"
      end
      expect(page).to have_content("Are you sure you want to refresh the secret for this API user?")
      click_link_or_button "OK"
      expect(page).to have_content("Secret refreshed successfully.")
      expect(page).to have_current_path("/system/api_users")
      expect(Decidim::Api::ApiUser.count).to eq(7)
      within refreshing_tr do
        expect(page).to have_button("Copy secret")
      end
      click_link_or_button("Copy secret")
      expect(page).to have_content("Copied")
    end

    it "creates new api user" do
      click_link_or_button "New API user"
      expect(page).to have_current_path("/system/api_users/new")
      expect(page).to have_content("Create new API user")
      expect(page).to have_content("Select your organization")
      click_link_or_button "Create"
      expect(page).to have_current_path("/system/api_users/new")
      select "#{translated(organization.name)} (#{organization.host})", from: "admin_organization"
      click_link_or_button "Create"
      expect(page).to have_current_path("/system/api_users/new")
      fill_in "Name", with: "Dummy name"
      within "select#admin_organization" do
        expect(page).to have_css("option", text: "#{translated(organization.name)} (#{organization.host})")
      end
      click_link_or_button "Create"
      expect(page).to have_content("API user created successfully.")
      current_url = URI.parse(page.current_path)
      expect(current_url.path).to eq("/system/api_users")
      within "table.stack" do
        expect(page).to have_content("Dummy name")
        new_tr = find("td", text: "Dummy name").find(:xpath, "..")
        within new_tr do
          expect(page).to have_content(dummy_token)
          expect(page).to have_button("Copy secret")
        end
      end
      click_link_or_button "Copy secret"
      expect(page).to have_no_link("Copy secret")
      expect(page).to have_content("Copied")
    end

    it "toggles masked secret by clicking 'show password' toggler" do
      click_link_or_button "New API user"
      select "#{translated(organization.name)} (#{organization.host})", from: "admin_organization"
      fill_in "Name", with: "Dummy name"
      click_link_or_button "Create"
      expect(page).to have_content("API user created successfully.")

      masked_user = Decidim::Api::ApiUser.order(:id).last
      secret_input = find("input#token_#{masked_user.id}")
      expect(secret_input[:type]).to eq("password")
      expect(secret_input.value).to eq(dummy_token)
      expect(page).to have_css('button[aria-label="Show password"]', count: 1)
      find('button[aria-label="Show password"]').click
      expect(secret_input[:type]).to eq("text")
    end
  end
end
