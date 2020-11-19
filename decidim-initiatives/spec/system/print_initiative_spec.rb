# frozen_string_literal: true

require "spec_helper"

describe "User prints the initiative", type: :system do
  context "when initiative print" do
    include_context "when admins initiative"
    let!(:initiative) do
      create(:initiative, organization: organization, scoped_type: initiative_scope, author: author, state: :accepted)
    end

    before do
      switch_to_host(organization.host)
      login_as author, scope: :user
      visit decidim_initiatives.initiative_path(initiative)

      page.find(".action-print").click
    end

    it "shows a printable form" do
      within "main" do
        expect(page).to have_content(translated(initiative.title, locale: :en))
        expect(page).to have_content(translated(initiative.type.title, locale: :en))
        expect(page).to have_content(ActionView::Base.full_sanitizer.sanitize(translated(initiative.description, locale: :en), tags: []))
      end
    end
  end
end
