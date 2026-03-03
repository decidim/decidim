# frozen_string_literal: true

require "spec_helper"

describe "redirect routes" do
  let!(:organization) { create(:organization) }
  let!(:type1) { create(:initiatives_type, organization:) }
  let!(:scoped_type1) { create(:initiatives_type_scope, type: type1) }

  before do
    switch_to_host(organization.host)
  end

  context "when requesting initiatives" do
    it "redirects old url with missing locale" do
      visit "/initiatives"
      expect(page).to have_current_path("/en/initiatives", ignore_query: true)
    end

    it "redirects old url with locale" do
      visit "/initiatives?locale=es"
      expect(page).to have_current_path("/es/initiatives", ignore_query: true)
    end

    it "redirects user to the new url" do
      user = create(:user, :confirmed, organization:, locale: "ca")
      login_as user, scope: :user
      visit "/"

      visit "/initiatives"
      expect(page).to have_current_path("/ca/initiatives", ignore_query: true)
    end

    it "redirects user to the new url when using custom locale" do
      user = create(:user, :confirmed, organization:, locale: "ca")
      login_as user, scope: :user
      visit "/"

      visit "/initiatives?locale=es"
      expect(page).to have_current_path("/es/initiatives", ignore_query: true)
    end

    it "redirects old url with locale and additional params" do
      visit "/initiatives/foo-bar?locale=es"
      expect(page).to have_current_path("/es/initiatives/foo-bar", ignore_query: true)
    end
  end

  context "when requesting initiatives types" do
    it "redirects old url with locale and additional params" do
      visit "/initiative_types/foo-bar?locale=es"
      expect(page).to have_current_path("/es/initiative_types/foo-bar", ignore_query: true)
    end
  end

  context "when requesting initiative type signature types" do
    it "redirects old url with locale and additional params" do
      visit "/initiative_type_signature_types/foo-bar?locale=es"
      expect(page).to have_current_path("/es/initiative_type_signature_types/foo-bar", ignore_query: true)
    end
  end
end
