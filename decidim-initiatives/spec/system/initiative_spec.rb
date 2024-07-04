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

    before do
      allow(Decidim::Initiatives).to receive(:print_enabled).and_return(true)
    end

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
                 organization: organization,
                 signature_start_date: 1.day.ago,
                 signature_end_date: 1.day.from_now,
                 state: state)
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
          create(:initiative, organization: organization, state: state, scoped_type: scoped_type)
        end

        let(:scoped_type) do
          create(:initiatives_type_scope,
                 type: create(:initiatives_type,
                              :with_comments_disabled,
                              organization: organization,
                              signature_type: "online"))
        end

        it "does not have comments" do
          expect(page).not_to have_css(".comments")
          expect(page).not_to have_content("0 Comments")
        end
      end
    end

    context "when I am the author of the initiative" do
      before do
        sign_in initiative.author
        visit decidim_initiatives.initiative_path(initiative)
      end

      shared_examples_for "initiative does not show send to technical validation" do
        it { expect(page).to have_no_link("Send to technical validation") }
      end

      context "when initiative state is created" do
        let(:state) { :created }

        context "when the user cannot send the initiative to technical validation" do
          before do
            initiative.committee_members.destroy_all
            visit decidim_initiatives.initiative_path(initiative)
          end

          it_behaves_like "initiative does not show send to technical validation"
          it { expect(page).to have_content("Before sending your initiative for technical validation") }
          it { expect(page).to have_link("Edit") }
        end

        context "when the user can send the initiative to technical validation" do
          it { expect(page).to have_link("Send to technical validation", href: decidim_initiatives.send_to_technical_validation_initiative_path(initiative)) }
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

      context "when initiative state is published" do
        let(:state) { :published }

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

    describe "follow button" do
      let!(:user) { create(:user, :confirmed, organization:) }
      let(:followable) { initiative }
      let(:followable_path) { decidim_initiatives.initiative_path(initiative) }

      include_examples "follows"
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
