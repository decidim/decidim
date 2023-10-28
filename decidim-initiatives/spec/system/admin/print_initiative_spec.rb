# frozen_string_literal: true

require "spec_helper"

describe "User prints the initiative" do
  context "when initiative print" do
    include_context "when admins initiative"

    before do
      allow(Decidim::Initiatives).to receive(:print_enabled).and_return(print_enabled)

      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_initiatives.initiatives_path
    end

    context "when the setting is enabled" do
      let(:print_enabled) { true }

      it "shows a printable form with all available data about the initiative" do
        new_window = window_opened_by { page.find(".action-icon--print").click }

        page.within_window(new_window) do
          expect(page).to have_content(translated(initiative.title, locale: :en))
          expect(page).to have_content(translated(initiative.type.title, locale: :en))
          expect(page).to have_content(ActionView::Base.full_sanitizer.sanitize(translated(initiative.description, locale: :en), tags: []))
        end
      end
    end

    context "when the setting is disabled" do
      let(:print_enabled) { false }

      it "does not show the print link" do
        expect(page).not_to have_css(".action-icon--print")
      end
    end
  end
end
