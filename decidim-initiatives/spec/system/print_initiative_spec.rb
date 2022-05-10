# frozen_string_literal: true

require "spec_helper"

describe "User prints the initiative", type: :system do
  context "when initiative print" do
    include_context "when admins initiative"
    let(:state) { :created }
    let!(:initiative) do
      create(:initiative, organization: organization, scoped_type: initiative_scope, author: author, state: state)
    end

    before do
      switch_to_host(organization.host)
      login_as author, scope: :user
      visit decidim_initiatives.initiative_path(initiative)

      page.find(".action-print").click
    end

    it "shows a printable form when created" do
      within "main" do
        expect(page).to have_content(translated(initiative.title, locale: :en))
        expect(page).to have_content(translated(initiative.type.title, locale: :en))
        expect(page).to have_content(ActionView::Base.full_sanitizer.sanitize(translated(initiative.description, locale: :en), tags: []))
      end
    end

    context "when sent to technical validation" do
      let(:state) { :validating }

      it "shows a printable form when validating" do
        within "main" do
          expect(page).to have_content(translated(initiative.title, locale: :en))
          expect(page).to have_content(translated(initiative.type.title, locale: :en))
          expect(page).to have_content(ActionView::Base.full_sanitizer.sanitize(translated(initiative.description, locale: :en), tags: []))
        end
      end
    end

    context "and the organization has a logo" do
      let(:organization) { create :organization, logo: Decidim::Dev.test_file("avatar.jpg", "image/jpeg") }

      it "shows a printable form when created" do
        within "main" do
          expect(page).to have_content(translated(initiative.title, locale: :en))
          expect(page).to have_content(translated(initiative.type.title, locale: :en))
          expect(page).to have_content(ActionView::Base.full_sanitizer.sanitize(translated(initiative.description, locale: :en), tags: []))
        end
      end
    end
  end
end
