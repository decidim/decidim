# frozen_string_literal: true

require "spec_helper"

describe "Access Mode Restricted Assemblies" do
  let!(:participatory_space) { create(:assembly, :published, organization:) }
  let!(:participatory_space_member) { create(:assembly_member, user: other_user, participatory_space: restricted_participatory_space) }
  let!(:participatory_space_member2) { create(:assembly_member, user: other_user2, participatory_space: restricted_participatory_space) }
  let!(:restricted_participatory_space) { create(:assembly, :published, organization:, access_mode: :restricted) }

  let(:participatory_space_index_path) { decidim_assemblies.assemblies_path(locale: I18n.locale) }
  let(:restricted_participatory_space_path) { decidim_assemblies.assembly_path(restricted_participatory_space, locale: I18n.locale) }
  let(:restricted_participatory_space_attachment_path) { decidim_admin_assemblies.assembly_attachments_path(restricted_participatory_space) }
  let(:css_class_selector) { "#assemblies-grid" }

  let!(:organization) { create(:organization) }
  let!(:admin) { create(:user, :admin, :confirmed, organization:) }
  let!(:user) { create(:user, :confirmed, organization:) }
  let!(:other_user) { create(:user, :confirmed, organization:) }
  let!(:other_user2) { create(:user, :confirmed, organization:) }

  context "and no user is logged in" do
    before do
      switch_to_host(organization.host)
      visit participatory_space_index_path
    end

    it "does not list the restricted participatory space" do
      within css_class_selector do
        within "#{css_class_selector} h2" do
          expect(page).to have_content("1")
        end

        expect(page).to have_content(translated(participatory_space.title, locale: :en))
        expect(page).to have_css(".card__grid", count: 1)

        expect(page).to have_no_content(translated(restricted_participatory_space.title, locale: :en))
      end
    end
  end

  context "when user is logged in and is not an participatory space member" do
    context "when the user is not admin" do
      before do
        switch_to_host(organization.host)
        login_as user, scope: :user
        visit participatory_space_index_path
      end

      it "does not list the restricted participatory space" do
        within css_class_selector do
          within "#{css_class_selector} h2" do
            expect(page).to have_content("1")
          end

          expect(page).to have_content(translated(participatory_space.title, locale: :en))
          expect(page).to have_css(".card__grid", count: 1)

          expect(page).to have_no_content(translated(restricted_participatory_space.title, locale: :en))
        end
      end
    end

    context "when the user is admin" do
      before do
        switch_to_host(organization.host)
        login_as admin, scope: :user
        visit participatory_space_index_path
      end

      it "lists restricted participatory sapces" do
        within css_class_selector do
          within "#{css_class_selector} h2" do
            expect(page).to have_content("2")
          end

          expect(page).to have_content(translated(participatory_space.title, locale: :en))
          expect(page).to have_content(translated(restricted_participatory_space.title, locale: :en))
          expect(page).to have_css(".card__grid", count: 2)
        end
      end

      it "links to the individual participatory space page" do
        first(".card__grid-text", text: translated(restricted_participatory_space.title, locale: :en)).click

        expect(page).to have_current_path restricted_participatory_space_path
        expect(page).to have_content "This is a restricted space"
      end

      it "shows the privacy warning in attachments admin" do
        visit restricted_participatory_space_attachment_path
        within "#attachments" do
          expect(page).to have_content("Any participant could share this document to others")
        end
      end
    end
  end

  context "when user is logged in and is an participatory space member" do
    before do
      switch_to_host(organization.host)
      login_as other_user, scope: :user
      visit participatory_space_index_path
    end

    it "lists restricted participatory spaces" do
      within css_class_selector do
        within "#{css_class_selector} h2" do
          expect(page).to have_content("2")
        end

        expect(page).to have_content(translated(participatory_space.title, locale: :en))
        expect(page).to have_content(translated(restricted_participatory_space.title, locale: :en))
        expect(page).to have_css(".card__grid", count: 2)
      end
    end

    it "links to the individual participatory space page" do
      first(".card__grid-text", text: translated(restricted_participatory_space.title, locale: :en)).click

      expect(page).to have_current_path restricted_participatory_space_path
      expect(page).to have_content "This is a restricted space"
    end
  end
end
