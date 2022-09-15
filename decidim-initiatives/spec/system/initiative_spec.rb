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
          expect(page).to have_css(".progress__bar__number")
          expect(page).to have_css(".progress__bar__text")
        end
      end

      shared_examples_for "initiative does not show signatures" do
        it "does not show signatures for the state" do
          expect(page).not_to have_css(".progress__bar__number")
          expect(page).not_to have_css(".progress__bar__text")
        end
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

      context "when signature interval is defined" do
        let(:base_initiative) do
          create(:initiative,
                 organization:,
                 signature_start_date: 1.day.ago,
                 signature_end_date: 1.day.from_now,
                 state:)
        end

        it "displays collection period" do
          within ".process-header__phase" do
            expect(page).to have_content("Signature collection period")
            expect(page).to have_content(1.day.ago.strftime("%Y-%m-%d"))
            expect(page).to have_content(1.day.from_now.strftime("%Y-%m-%d"))
          end
        end
      end

      it_behaves_like "initiative shows signatures"

      it "shows the author name once in the authors list" do
        within ".initiative-authors" do
          expect(page).to have_content(initiative.author_name, count: 1)
        end
      end

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

      it_behaves_like "has attachments"

      it "displays comments section" do
        expect(page).to have_css(".comments")
        expect(page).to have_content("0 Comments")
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
          expect(page).not_to have_content("0 Comments")
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
        within ".process-nav" do
          expect(page).to have_content(translated(meetings_component.name, locale: :en).upcase)
          expect(page).to have_no_content(translated(proposals_component.name, locale: :en).upcase)
        end
      end

      it "allows visiting the components" do
        within ".process-nav" do
          click_link translated(meetings_component.name, locale: :en)
        end
        expect(page).to have_content("3 MEETINGS")
      end
    end
  end
end
