# frozen_string_literal: true

require "spec_helper"

describe "Initiative", type: :system do
  let(:organization) { create(:organization) }
  let(:state) { :published }
  let(:base_initiative) do
    create(:initiative, organization: organization, state: state)
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

    it_behaves_like "editable content for admins" do
      let(:target_path) { decidim_initiatives.initiative_path(initiative) }
    end

    context "when requesting the initiative path" do
      before do
        visit decidim_initiatives.initiative_path(initiative)
      end

      it "shows the details of the given initiative" do
        within "main" do
          expect(page).to have_content(translated(initiative.title, locale: :en))
          expect(page).to have_content(ActionView::Base.full_sanitizer.sanitize(translated(initiative.description, locale: :en), tags: []))
          expect(page).to have_content(translated(initiative.type.title, locale: :en))
          expect(page).to have_content(translated(initiative.scope.name, locale: :en))
          expect(page).to have_content(initiative.author_name)
          expect(page).to have_content(initiative.hashtag)
          expect(page).to have_content(initiative.reference)
        end
      end

      it "shows signatures when published" do
        expect(page).to have_css(".progress__bar__number")
        expect(page).to have_css(".progress__bar__text")
      end

      it "shows the author name once in the authors list" do
        within ".initiative-authors" do
          expect(page).to have_content(initiative.author_name, count: 1)
        end
      end

      context "when initiative state is rejected" do
        let(:state) { :rejected }

        it "shows signatures" do
          expect(page).to have_css(".progress__bar__number")
          expect(page).to have_css(".progress__bar__text")
        end
      end

      context "when initiative state is accepted" do
        let(:state) { :accepted }

        it "shows signatures" do
          expect(page).to have_css(".progress__bar__number")
          expect(page).to have_css(".progress__bar__text")
        end
      end

      context "when initiative state is created" do
        let(:state) { :created }

        it "does not show signatures" do
          expect(page).not_to have_css(".progress__bar__number")
          expect(page).not_to have_css(".progress__bar__text")
        end
      end

      context "when initiative state is validating" do
        let(:state) { :validating }

        it "does not show signatures" do
          expect(page).not_to have_css(".progress__bar__number")
          expect(page).not_to have_css(".progress__bar__text")
        end
      end

      context "when initiative state is discarded" do
        let(:state) { :discarded }

        it "does not show signatures" do
          expect(page).not_to have_css(".progress__bar__number")
          expect(page).not_to have_css(".progress__bar__text")
        end
      end

      it_behaves_like "has attachments"
    end
  end
end
