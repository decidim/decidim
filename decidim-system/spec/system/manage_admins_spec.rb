# frozen_string_literal: true

require "spec_helper"

describe "Manage admins" do
  let(:admin) { create(:admin) }
  let!(:admin2) { create(:admin) }

  before do
    login_as admin, scope: :admin
    visit decidim_system.admins_path
  end

  describe "when creating a new admin" do
    context "with a valid password" do
      it "is created" do
        click_on "New"

        within ".new_admin" do
          fill_in :admin_email, with: "admin@foo.bar"
          fill_in :admin_password, with: "decidim123456789"
          fill_in :admin_password_confirmation, with: "decidim123456789"

          find("*[type=submit]").click
        end

        within ".success.flash" do
          expect(page).to have_content("successfully")
        end

        within "table" do
          expect(page).to have_content("admin@foo.bar")
        end
      end
    end

    context "with an invalid password" do
      it "gives an error" do
        click_on "New"

        within ".new_admin" do
          fill_in :admin_email, with: "admin@foo.bar"
          fill_in :admin_password, with: "password1234"
          fill_in :admin_password_confirmation, with: "password1234"

          find("*[type=submit]").click
        end

        expect(page).to have_css(".form-error.is-visible", text: "is too common")
      end
    end
  end

  describe "when updating an admin" do
    context "with a valid password" do
      it "is updated" do
        within "tr", text: admin.email do
          click_on "Edit"
        end

        within ".edit_admin" do
          fill_in :admin_email, with: "admin@another.domain"

          find("*[type=submit]").click
        end

        within ".success.flash" do
          expect(page).to have_content("successfully")
        end

        within "table" do
          expect(page).to have_content("admin@another.domain")
        end
      end
    end

    context "with an invalid password" do
      it "gives an error" do
        within "tr", text: admin.email do
          click_on "Edit"
        end

        within ".edit_admin" do
          fill_in :admin_password, with: "password1234"
          fill_in :admin_password_confirmation, with: "password1234"

          find("*[type=submit]").click
        end

        expect(page).to have_css(".form-error.is-visible", text: "is too common")
      end
    end
  end

  it "deletes an admin" do
    within "tr", text: admin2.email do
      accept_confirm { click_on "Delete" }
    end

    within ".success.flash" do
      expect(page).to have_content("successfully")
    end

    within "table" do
      expect(page).to have_no_content(admin2.email)
    end
  end

  it "cannot delete admin rights from self" do
    within "tr", text: admin.email do
      expect(page).to have_no_link("Delete", visible: :hidden)
    end
  end
end
