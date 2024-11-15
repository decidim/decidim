# frozen_string_literal: true

require "spec_helper"

describe "User prints the initiative" do
  context "when initiative print" do
    context "when user is unauthenticated" do
      include_context "when admins initiative"

      before do
        allow(Decidim::Initiatives).to receive(:print_enabled).and_return(print_enabled)
        switch_to_host(organization.host)
        visit decidim_initiatives.print_initiative_path(initiative)
      end

      context "when the setting is enabled" do
        let(:print_enabled) { true }

        it "redirects to the login page" do
          expect(page).to have_current_path("/users/sign_in")
          expect(page).to have_content("You are not authorized to perform this action.")
        end
      end

      context "when the setting is disabled" do
        let(:print_enabled) { false }

        it "does not show the print link" do
          expect(page).to have_current_path("/users/sign_in")
        end
      end
    end

    context "when is regular user" do
      include_context "when admins initiative"
      let(:user) { create(:user, :confirmed, organization:) }

      before do
        allow(Decidim::Initiatives).to receive(:print_enabled).and_return(print_enabled)
        switch_to_host(organization.host)
        login_as user, scope: :user
        visit decidim_initiatives.print_initiative_path(initiative)
      end

      context "when the setting is enabled" do
        let(:print_enabled) { true }

        it "redirects to the home page" do
          expect(page).to have_current_path(decidim.root_path)
          expect(page).to have_content("You are not authorized to perform this action.")
        end
      end

      context "when the setting is disabled" do
        let(:print_enabled) { false }

        it "does not show the print link" do
          expect(page).to have_current_path(decidim.root_path)
        end
      end
    end

    context "when user is the author" do
      include_context "when admins initiative"
      let(:user) { author }

      before do
        allow(Decidim::Initiatives).to receive(:print_enabled).and_return(print_enabled)

        switch_to_host(organization.host)
        login_as user, scope: :user
        visit decidim_initiatives.print_initiative_path(initiative)
      end

      context "when the setting is enabled" do
        let(:print_enabled) { true }

        it "shows a printable form with all available data about the initiative" do
          expect(page).to have_current_path(decidim_initiatives.print_initiative_path(initiative))
          expect(page).to have_content(translated(initiative.title, locale: :en))
          expect(page).to have_content(translated(initiative.type.title, locale: :en))
          expect(page).to have_content(ActionView::Base.full_sanitizer.sanitize(translated(initiative.description, locale: :en), tags: []))
        end
      end

      context "when the setting is disabled" do
        let(:print_enabled) { false }

        it "does not show the print link" do
          expect(page).to have_current_path(decidim.root_path)
        end
      end
    end

    context "when user is the committee" do
      include_context "when admins initiative"
      let(:user) { create(:user, :confirmed, organization:) }
      let!(:initiatives_committee_member) { create(:initiatives_committee_member, initiative:, user:) }

      before do
        allow(Decidim::Initiatives).to receive(:print_enabled).and_return(print_enabled)

        switch_to_host(organization.host)
        login_as user, scope: :user
        visit decidim_initiatives.print_initiative_path(initiative)
      end

      context "when the setting is enabled" do
        let(:print_enabled) { true }

        it "shows a printable form with all available data about the initiative" do
          expect(page).to have_current_path(decidim_initiatives.print_initiative_path(initiative))
          expect(page).to have_content(translated(initiative.title, locale: :en))
          expect(page).to have_content(translated(initiative.type.title, locale: :en))
          expect(page).to have_content(ActionView::Base.full_sanitizer.sanitize(translated(initiative.description, locale: :en), tags: []))
        end
      end

      context "when the setting is disabled" do
        let(:print_enabled) { false }

        it "does not show the print link" do
          expect(page).to have_current_path(decidim.root_path)
        end
      end
    end

    context "when user is admin" do
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
          expect(page).to have_no_css(".action-icon--print")
        end
      end
    end
  end
end
