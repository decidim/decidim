# frozen_string_literal: true

require "spec_helper"

describe "Access Mode Transparent Assemblies" do
  let!(:organization) { create(:organization) }
  let!(:assembly) { create(:assembly, :published, organization:) }
  let!(:admin) { create(:user, :admin, :confirmed, organization:) }
  let!(:user) { create(:user, :confirmed, organization:) }
  let!(:other_user) { create(:user, :confirmed, organization:) }
  let!(:other_user2) { create(:user, :confirmed, organization:) }
  let!(:assembly_member) { create(:assembly_member, user: other_user, participatory_space: transparent_assembly) }
  let!(:assembly_member2) { create(:assembly_member, user: other_user2, participatory_space: transparent_assembly) }

  let!(:transparent_assembly) { create(:assembly, :published, :transparent, organization:) }

  context "and no user is logged in" do
    before do
      switch_to_host(organization.host)
      visit decidim_assemblies.assemblies_path(locale: I18n.locale)
    end

    it "lists all the assemblies" do
      within "#assemblies-grid" do
        within "#assemblies-grid h2" do
          expect(page).to have_content("2")
        end

        expect(page).to have_content(translated(assembly.title, locale: :en))
        expect(page).to have_css(".card__grid", count: 2)

        expect(page).to have_content(translated(transparent_assembly.title, locale: :en))
      end
    end

    it "links to the individual assembly page" do
      first(".card__grid-text", text: translated(transparent_assembly.title, locale: :en)).click

      expect(page).to have_current_path decidim_assemblies.assembly_path(transparent_assembly, locale: I18n.locale)
      expect(page).to have_content "This is a transparent space"
    end
  end

  context "when user is logged in" do
    context "when is not an assembly member" do
      before do
        switch_to_host(organization.host)
        login_as user, scope: :user
        visit decidim_assemblies.assemblies_path(locale: I18n.locale)
      end

      it "lists all the assemblies" do
        within "#assemblies-grid" do
          within "#assemblies-grid h2" do
            expect(page).to have_content("2")
          end

          expect(page).to have_content(translated(assembly.title, locale: :en))
          expect(page).to have_css(".card__grid", count: 2)

          expect(page).to have_content(translated(transparent_assembly.title, locale: :en))
        end
      end
    end

    context "when the user is admin" do
      before do
        switch_to_host(organization.host)
        login_as admin, scope: :user
        visit decidim_assemblies.assemblies_path(locale: I18n.locale)
      end

      it "does not show the privacy warning in attachments admin" do
        visit decidim_admin_assemblies.assembly_attachments_path(transparent_assembly)
        within "#attachments" do
          expect(page).to have_no_content("Any participant could share this document to others")
        end
      end
    end
  end
end
