# frozen_string_literal: true

require "spec_helper"

describe "Admin language selector" do
  let(:admin) { create(:user, :admin, :confirmed, organization:) }
  let!(:locales) do
    I18n.available_locales = available_locales
    Decidim.available_locales = available_locales
  end
  let(:organization) { create(:organization, available_locales:) }

  before do
    # Reload the StaticPageForm
    Decidim::Admin.send(:remove_const, :StaticPageForm)
    load "#{Decidim::Admin::Engine.root}/app/forms/decidim/admin/static_page_form.rb"
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin.root_path
    click_on "Pages"
    click_on "Create page"
  end

  after do
    Decidim.available_locales = %w(en ca es)
    I18n.available_locales = %w(en ca es)
    Decidim::Admin.send(:remove_const, :StaticPageForm)
    load "#{Decidim::Admin::Engine.root}/app/forms/decidim/admin/static_page_form.rb"
    I18n.backend.reload!
  end

  context "with less than 5 fields" do
    let!(:available_locales) do
      locales = %w(ro fi en)
      I18n.available_locales = locales
      Decidim.available_locales = locales
      I18n.backend.reload!
      locales
    end

    it "displays Romanian fields" do
      expect(page).to have_css("#static_page_title_ro", visible: :hidden)
      within "#static_page-title-tabs" do
        click_on "Română"
      end
      expect(page).to have_css("#static_page_title_ro", visible: :visible)
    end

    it "displays Finnish fields" do
      expect(page).to have_css("#static_page_title_fi", visible: :hidden)
      within "#static_page-title-tabs" do
        click_on "Suomi"
      end
      expect(page).to have_css("#static_page_title_fi", visible: :visible)
    end
  end

  context "with more than 5 fields" do
    let!(:available_locales) do
      locales = %w(en ro es ca it fi)
      I18n.available_locales = locales
      Decidim.available_locales = locales
      I18n.backend.reload!
      locales
    end

    it "displays Romanian fields" do
      expect(page).to have_css("#static_page_title_ro", visible: :hidden)
      select "Română", from: "static_page-title-tabs"
      expect(page).to have_css("#static_page_title_ro", visible: :visible)
    end

    it "displays Finnish fields" do
      expect(page).to have_css("#static_page_title_fi", visible: :hidden)
      select "Suomi", from: "static_page-title-tabs"
      expect(page).to have_css("#static_page_title_fi", visible: :visible)
    end
  end
end
