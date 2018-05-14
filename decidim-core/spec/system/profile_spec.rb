# frozen_string_literal: true

require "spec_helper"

describe "Profile", type: :system do
  let(:user) { create(:user, :confirmed) }

  before do
    switch_to_host(user.organization.host)
  end

  context "when navigating privately" do
    before do
      login_as user, scope: :user
    end

    it "shows the profile page when clicking on the menu" do
      visit decidim.root_path

      within_user_menu do
        find("a", text: "profile").click
      end

      expect(page).to have_title(user.nickname)
    end
  end

  context "when navigating publicly" do
    before do
      visit decidim.profile_path(user.nickname)
    end

    it "shows user name in the header, its nickname and a contact link" do
      expect(page).to have_selector("h1", text: user.name)
      expect(page).to have_content(user.nickname)
      expect(page).to have_link("Contact")
    end

    it "does not show officialization stuff" do
      expect(page).to have_no_content("This participant is publicly verified")
    end

    context "and user officialized the standard way" do
      let(:user) { create(:user, :officialized, officialized_as: nil) }

      it "shows officialization status" do
        expect(page).to have_content("This participant is publicly verified")
      end
    end

    context "and user officialized with a custom badge" do
      let(:user) do
        create(:user, :officialized, officialized_as: { "en" => "Major of Barcelona" })
      end

      it "shows officialization status" do
        expect(page).to have_content("Major of Barcelona")
      end
    end
  end

  describe "view hooks" do
    before do
      allow(Decidim.view_hooks)
        .to receive(:render)
        .with(a_kind_of(Symbol), a_kind_of(ActionView::Base))
        .and_return("Rendered from #{view_hook} view hook")

      visit decidim.profile_path(user.nickname)
    end

    context "with user_profile_bottom view hook" do
      let(:view_hook) { :user_profile_bottom }

      it "renders the view hook" do
        expect(Decidim.view_hooks).to have_received(:render).with(:user_profile_bottom, a_kind_of(ActionView::Base))
        expect(page).to have_content("Rendered from user_profile_bottom view hook")
      end
    end
  end
end
