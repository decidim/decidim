# frozen_string_literal: true

require "spec_helper"

describe "User previews initiative" do
  include_context "when admins initiative"

  context "when initiative preview" do
    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_initiatives.initiatives_path
    end

    it "shows the details of the given initiative" do
      preview_window = window_opened_by do
        within("tr", text: translated(initiative.title)) do
          find("button[data-component='dropdown']").click
          click_on "Preview"
        end
      end

      within_window(preview_window) do
        within "[data-content]" do
          expect(page).to have_content(translated(initiative.title, locale: :en))
          expect(page).to have_content(ActionView::Base.full_sanitizer.sanitize(translated(initiative.description, locale: :en), tags: []))
          expect(page).to have_content(translated(initiative.type.title, locale: :en))
          expect(page).to have_content(translated(initiative.scope.name, locale: :en))
        end
      end
    end
  end
end
