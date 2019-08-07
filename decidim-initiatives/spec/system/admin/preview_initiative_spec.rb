# frozen_string_literal: true

require "spec_helper"

describe "User previews initiative", type: :system do
  include_context "when admins initiative"

  context "when initiative preview" do
    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_initiatives.initiatives_path
    end

    it "shows the details of the given initiative" do
      preview_window = window_opened_by do
        page.find(".action-icon--preview").click
      end

      within_window(preview_window) do
        within "main" do
          expect(page).to have_content(translated(initiative.title, locale: :en))
          expect(page).to have_content(ActionView::Base.full_sanitizer.sanitize(translated(initiative.description, locale: :en), tags: []))
          expect(page).to have_content(translated(initiative.type.title, locale: :en))
          expect(page).to have_content(translated(initiative.scope.name, locale: :en))
          expect(page).to have_content(initiative.author_name)
          expect(page).to have_content(initiative.hashtag)
        end
      end
    end
  end
end
