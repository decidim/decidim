# frozen_string_literal: true

require "spec_helper"

describe "Initiative" do
  let(:organization) { create(:organization) }
  let(:state) { :open }
  let(:base_initiative) do
    create(:initiative, organization:, state:)
  end

  before do
    switch_to_host(organization.host)
  end

  context "when the initiative does not exist" do
    it_behaves_like "a 404 page" do
      let(:target_path) { decidim_initiatives.initiative_path(99_999_999, locale: I18n.locale) }
    end
  end

  describe "initiative page" do
    let!(:initiative) { base_initiative }
    let(:attached_to) { initiative }

    before do
      allow(Decidim::Initiatives).to receive(:print_enabled).and_return(true)
    end

    it_behaves_like "editable content for admins" do
      let(:target_path) { decidim_initiatives.initiative_path(initiative, locale: I18n.locale) }
    end

    context "when requesting the initiative path" do
      before do
        visit decidim_initiatives.initiative_path(initiative, locale: I18n.locale)
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
          expect(page).to have_no_css(".progress-bar__container")
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

      it_behaves_like "has attachments tabs"

      context "when the initiative is not published" do
        let(:state) { :created }

        before do
          initiative.update!(published_at: nil)
        end

        it "does not display comments section" do
          expect(page).to have_no_css(".comments")
          expect(page).to have_no_content("0 comments")
        end
      end

      context "when the initiative is published" do
        it "displays comments section" do
          expect(page).to have_css(".comments")
          expect(page).to have_content("0 comments")
        end
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
          expect(page).to have_no_css(".comments")
          expect(page).to have_no_content("0 comments")
        end
      end
    end

    context "when I am the author of the initiative" do
      before do
        sign_in initiative.author
        visit decidim_initiatives.initiative_path(initiative, locale: I18n.locale)
      end

      shared_examples_for "initiative does not show send to technical validation" do
        it { expect(page).to have_no_link("Send to technical validation") }
      end

      context "when initiative state is created" do
        let(:state) { :created }

        context "when the user cannot send the initiative to technical validation" do
          before do
            initiative.update!(published_at: nil)
            initiative.committee_members.destroy_all
            visit decidim_initiatives.initiative_path(initiative, locale: I18n.locale)
          end

          it_behaves_like "initiative does not show send to technical validation"
          it { expect(page).to have_content("Before sending your initiative for technical validation") }
          it { expect(page).to have_link("Edit") }
        end

        context "when the user can send the initiative to technical validation" do
          before do
            initiative.update!(published_at: nil)
            visit decidim_initiatives.initiative_path(initiative, locale: I18n.locale)
          end

          it { expect(page).to have_link("Send to technical validation", href: decidim_initiatives.send_to_technical_validation_initiative_path(initiative, locale: I18n.locale)) }
          it { expect(page).to have_content('If everything looks ok, click on "Send to technical validation" for an administrator to review and publish your initiative') }
        end
      end

      context "when initiative state is validating" do
        let(:state) { :validating }

        it { expect(page).to have_no_link("Edit") }

        it_behaves_like "initiative does not show send to technical validation"
      end

      context "when initiative state is discarded" do
        let(:state) { :discarded }

        it_behaves_like "initiative does not show send to technical validation"
      end

      context "when initiative state is open" do
        let(:state) { :open }

        it_behaves_like "initiative does not show send to technical validation"
      end

      context "when initiative state is rejected" do
        let(:state) { :rejected }

        it_behaves_like "initiative does not show send to technical validation"
      end

      context "when initiative state is accepted" do
        let(:state) { :accepted }

        it_behaves_like "initiative does not show send to technical validation"
      end
    end
  end

  it_behaves_like "followable space content for users" do
    let(:initiative) { base_initiative }
    let!(:user) { create(:user, :confirmed, organization:) }
    let(:followable) { initiative }
    let(:followable_path) { decidim_initiatives.initiative_path(initiative, locale: I18n.locale) }
  end

  describe "initiative components" do
    let!(:initiative) { base_initiative }
    let!(:meetings_component) { create(:component, :published, participatory_space: initiative, manifest_name: :meetings) }
    let!(:proposals_component) { create(:component, :unpublished, participatory_space: initiative, manifest_name: :proposals) }
    let!(:blogs_component) { create(:component, :published, participatory_space: initiative, manifest_name: :blogs) }

    before do
      create_list(:meeting, 3, :published, component: meetings_component)
      allow(Decidim).to receive(:component_manifests).and_return([meetings_component.manifest, proposals_component.manifest, blogs_component.manifest])
    end

    context "when requesting the initiative path" do
      before { visit decidim_initiatives.initiative_path(initiative, locale: I18n.locale) }

      it "shows the components" do
        within ".participatory-space__nav-container" do
          expect(page).to have_content(translated(meetings_component.name, locale: :en))
          expect(page).to have_no_content(translated(proposals_component.name, locale: :en))
          expect(page).to have_content(translated(blogs_component.name, locale: :en))
        end
      end

      it "allows visiting the components" do
        within ".participatory-space__nav-container" do
          click_on translated(meetings_component.name, locale: :en)
        end

        expect(page).to have_css('[id^="meetings__meeting"]', count: 3)
      end
    end

    context "when signed in as the author of the initiative" do
      before do
        sign_in initiative.author
        visit decidim_initiatives.initiative_path(initiative, locale: I18n.locale)
      end

      it "has special permissions to create posts" do
        within ".participatory-space__nav-container" do
          click_on translated(blogs_component.name, locale: :en)
        end

        expect(page).to have_content("New post")
      end

      it "has special permissions to create meetings" do
        within ".participatory-space__nav-container" do
          click_on translated(meetings_component.name, locale: :en)
        end

        expect(page).to have_content("New meeting")
      end
    end
  end
end
