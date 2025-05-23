# frozen_string_literal: true

require "spec_helper"

describe "Admin manages organization" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  describe "edit" do
    context "when the HTML header snippets feature is enabled" do
      before do
        allow(Decidim).to receive(:enable_html_header_snippets).and_return(true)
      end

      it "shows the HTML header snippet form field" do
        visit decidim_admin.edit_organization_appearance_path

        expect(page).to have_field(:organization_header_snippets)
      end
    end

    context "when the HTML header snippets feature is disabled" do
      before do
        allow(Decidim).to receive(:enable_html_header_snippets).and_return(false)
      end

      it "does not show the HTML header snippet form field" do
        visit decidim_admin.edit_organization_appearance_path

        expect(page).to have_no_field(:organization_header_snippets)
      end
    end
  end
end
