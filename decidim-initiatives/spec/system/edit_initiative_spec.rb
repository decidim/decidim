# frozen_string_literal: true

require "spec_helper"

describe "Edit initiative", type: :system do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization:) }
  let(:initiative_title) { translated(initiative.title) }
  let(:new_title) { "This is my initiative new title" }

  let!(:initiative_type) { create(:initiatives_type, :online_signature_enabled, organization:) }
  let!(:scoped_type) { create(:initiatives_type_scope, type: initiative_type) }

  let!(:other_initiative_type) { create(:initiatives_type, organization:) }
  let!(:other_scoped_type) { create(:initiatives_type_scope, type: initiative_type) }

  let(:initiative_path) { decidim_initiatives.initiative_path(initiative) }
  let(:edit_initiative_path) { decidim_initiatives.edit_initiative_path(initiative) }

  shared_examples "manage update" do
    it "can be updated" do
      visit initiative_path

      click_link("Edit", href: edit_initiative_path)

      expect(page).to have_content "EDIT INITIATIVE"

      within "form.edit_initiative" do
        fill_in :initiative_title, with: new_title
        click_button "Update"
      end

      expect(page).to have_content(new_title)
    end
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  describe "when user is initiative author" do
    let(:initiative) { create(:initiative, :created, author: user, scoped_type:, organization:) }

    it_behaves_like "manage update"

    it "doesn't show the header's edit link" do
      visit initiative_path

      within ".topbar" do
        expect(page).not_to have_link("Edit")
      end
    end

    context "when initiative is published" do
      let(:initiative) { create(:initiative, author: user, scoped_type:, organization:) }

      it "can't be updated" do
        visit decidim_initiatives.initiative_path(initiative)

        expect(page).not_to have_content "Edit initiative"

        visit edit_initiative_path

        expect(page).to have_content("not authorized")
      end
    end
  end

  describe "when author is a committee member" do
    let(:initiative) { create(:initiative, :created, scoped_type:, organization:) }

    before do
      create(:initiatives_committee_member, user:, initiative:)
    end

    it_behaves_like "manage update"
  end

  describe "when user is admin" do
    let(:user) { create(:user, :confirmed, :admin, organization:) }
    let(:initiative) { create(:initiative, :created, scoped_type:, organization:) }

    it_behaves_like "manage update"
  end

  describe "when author is not a committee member" do
    let(:initiative) { create(:initiative, :created, scoped_type:, organization:) }

    it "renders an error" do
      visit decidim_initiatives.initiative_path(initiative)

      expect(page).to have_no_content("Edit initiative")

      visit edit_initiative_path

      expect(page).to have_content("not authorized")
    end
  end
end
