# frozen_string_literal: true

require "spec_helper"

describe "Initiative", type: :system do
  let(:organization) { create(:organization) }
  let(:state) { :published }
  let(:base_initiative) do
    create(:initiative, organization:, state:)
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

      shared_examples_for "initiative shows signatures" do
        it "shows signatures for the state" do
          within ".progress-bar__number" do
            expect(page).to have_css("span", count: 2)
          end
        end
      end

      shared_examples_for "initiative does not show signatures" do
        it "does not show signatures for the state" do
          expect(page).not_to have_css(".progress-bar__container")
        end
      end

      it "shows the details of the given initiative" do
        within "[data-content]" do
          expect(page).to have_content(translated(initiative.title, locale: :en))
          expect(page).to have_content(ActionView::Base.full_sanitizer.sanitize(translated(initiative.description, locale: :en), tags: []))
          expect(page).to have_content(translated(initiative.type.title, locale: :en))
          expect(page).to have_content(translated(initiative.scope.name, locale: :en))
          expect(page).to have_content(initiative.reference)
        end
      end

      context "when signature interval is defined" do
        let(:base_initiative) do
          create(:initiative,
                 organization:,
                 signature_start_date: 1.day.ago,
                 signature_end_date: 1.day.from_now,
                 state:)
        end

        it "displays collection period" do
          within ".initiatives__card__grid-metadata-dates" do
            expect(page).to have_content(1.day.ago.strftime("%d %b"))
            expect(page).to have_content(1.day.from_now.strftime("%d %b"))
          end
        end
      end

      it_behaves_like "initiative shows signatures"

      context "when initiative state is rejected" do
        let(:state) { :rejected }

        it_behaves_like "initiative shows signatures"
      end

      context "when initiative state is accepted" do
        let(:state) { :accepted }

        it_behaves_like "initiative shows signatures"
      end

      context "when initiative state is created" do
        let(:state) { :created }

        it_behaves_like "initiative does not show signatures"
      end

      context "when initiative state is validating" do
        let(:state) { :validating }

        it_behaves_like "initiative does not show signatures"
      end

      context "when initiative state is discarded" do
        let(:state) { :discarded }

        it_behaves_like "initiative does not show signatures"
      end

      it_behaves_like "has redesigned attachments"

      it "displays comments section" do
        expect(page).to have_css(".comments")
        expect(page).to have_content("0 comments")
      end

      context "when comments are disabled" do
        let(:base_initiative) do
          create(:initiative, organization:, state:, scoped_type:)
        end

        let(:scoped_type) do
          create(:initiatives_type_scope,
                 type: create(:initiatives_type,
                              :with_comments_disabled,
                              organization:,
                              signature_type: "online"))
        end

        it "does not have comments" do
          expect(page).not_to have_css(".comments")
          expect(page).not_to have_content("0 comments")
        end
      end
    end
  end

  describe "initiative components" do
    let!(:initiative) { base_initiative }
    let!(:meetings_component) { create(:component, :published, participatory_space: initiative, manifest_name: :meetings) }
    let!(:proposals_component) { create(:component, :unpublished, participatory_space: initiative, manifest_name: :proposals) }

    before do
      create_list(:meeting, 3, :published, component: meetings_component)
      allow(Decidim).to receive(:component_manifests).and_return([meetings_component.manifest, proposals_component.manifest])
    end

    context "when requesting the initiative path" do
      before { visit decidim_initiatives.initiative_path(initiative) }

      it "shows the components" do
        within ".participatory-space__nav-container" do
          expect(page).to have_content(translated(meetings_component.name, locale: :en))
          expect(page).not_to have_content(translated(proposals_component.name, locale: :en))
        end
      end

      it "allows visiting the components" do
        within ".participatory-space__nav-container" do
          click_link translated(meetings_component.name, locale: :en)
        end

        expect(page).to have_selector('[id^="meetings__meeting"]', count: 3)
      end
    end
  end
end
