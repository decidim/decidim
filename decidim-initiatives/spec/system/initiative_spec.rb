# frozen_string_literal: true

require "spec_helper"

describe "Initiative", type: :system do
  let(:organization) { create(:organization) }
  let(:base_initiative) do
    create(:initiative, organization: organization)
  end

  before do
    switch_to_host(organization.host)
  end

  context "when the initiative does not exist" do
    it_behaves_like "a 404 page" do
      let(:target_path) { decidim_initiatives.initiative_path(99_999_999) }
    end
  end

  describe "initiative page" do
    let!(:initiative) { base_initiative }
    let(:attached_to) { initiative }

    before do
      visit decidim_initiatives.initiative_path(initiative)
    end

    it_behaves_like "editable content for admins"

    it "shows the details of the given initiative" do
      within "main" do
        expect(page).to have_content(translated(initiative.title, locale: :en))
        expect(page).to have_content(ActionView::Base.full_sanitizer.sanitize(translated(initiative.description, locale: :en), tags: []))
        expect(page).to have_content(translated(initiative.type.title, locale: :en))
        expect(page).to have_content(translated(initiative.scope.name, locale: :en))
        expect(page).to have_content(initiative.author_name)
        expect(page).to have_content(initiative.hashtag)
      end
    end

    it_behaves_like "has attachments"
  end
end
