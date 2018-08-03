# frozen_string_literal: true

require "spec_helper"

describe "Explore Collaborative Drafts", versioning: true, type: :system do
  include_context "with a component"

  let(:manifest_name) { "proposals" }
  let!(:scope) { create :scope, organization: organization }
  let!(:author) { create :user, :confirmed, organization: organization }
  let!(:user) { create :user, :confirmed, organization: organization }
  let(:participatory_process) { create(:participatory_process, :with_steps, organization: organization) }
  let!(:component) do
    create(:proposal_component,
           :with_creation_enabled,
           :with_collaborative_drafts_enabled,
           manifest: manifest,
           participatory_space: participatory_process,
           organization: organization)
  end
  let!(:category) { create :category, participatory_space: participatory_process }
  let!(:category2) { create :category, participatory_space: participatory_process }
  let!(:category3) { create :category, participatory_space: participatory_process }
  let!(:collaborative_draft) { create(:collaborative_draft, :open, component: component, category: category, scope: scope, users: [author]) }
  let!(:collaborative_draft_no_tags) { create(:collaborative_draft, :open, component: component) }

  let!(:open_collaborative_draft) { create(:collaborative_draft, :open, component: component, category: category) }
  let!(:withdrawn_collaborative_draft) { create(:collaborative_draft, :withdrawn, component: component, category: category2) }
  let!(:published_collaborative_draft) { create(:collaborative_draft, :published, component: component, category: category3) }

  context "with collaborative drafts enabled" do
    before do
      visit main_component_path(component)
      click_link "Access collaborative drafts"
    end

    describe "Renders collaborative drafts index" do
      it "shows Open Drafts by default" do
        first ".card__text--paragraph" do
          expect(page).to have_css(".success.card__text--status", text: "OPEN")
        end
        within ".filters" do
          expect(find_field("filter_state_open")).to be_checked
        end
      end

      it "renders links to each collaborative draft details" do
        collaborative_drafts_count = Decidim::Proposals::CollaborativeDraft.open.where(component: component).count
        expect(page).to have_css(".card.card--collaborative_draft.success", count: collaborative_drafts_count)
        expect(page).to have_css(".card__button.button", count: collaborative_drafts_count)
        first ".card__support" do
          expect(page).to have_css(".card__button.button", text: "View Collaborative Draft")
        end
      end

      it "shows state filters" do
        within ".filters" do
          expect(page).to have_field("All")
          expect(page).to have_field("Open")
          expect(page).to have_field("Withdrawn")
          expect(page).to have_field("Published")
        end
      end

      it "shows category filters" do
        within ".filters" do
          expect(page).to have_css("#filter_category_id")
        end
      end
    end

    describe "renders collaborative draft details" do
      before do
        within "#collaborative_draft_#{collaborative_draft.id}" do
          click_link "View Collaborative Draft"
        end
      end

      it "shows the title" do
        expect(page).to have_content(collaborative_draft.title)
      end

      it "shows the body" do
        expect(page).to have_content(collaborative_draft.body)
      end

      it "shows the state" do
        expect(page).to have_css(".label.collaborative-draft-status", text: translated(collaborative_draft.state))
      end

      context "without category or scope" do
        before do
          visit_component
          click_link "Access collaborative drafts"
          within "#collaborative_draft_#{collaborative_draft_no_tags.id}" do
            click_link "View Collaborative Draft"
          end
        end

        it "does not show any tag" do
          expect(page).not_to have_selector("ul.tags.tags--collaborative-draft")
        end
      end

      context "with a category" do
        it "shows tags for category" do
          expect(page).to have_selector("ul.tags.tags--collaborative-draft")
          within "ul.tags.tags--collaborative-draft" do
            expect(page).to have_content(translated(collaborative_draft.category.name))
          end
        end
      end

      context "with a scope" do
        it "shows tags for scope" do
          expect(page).to have_selector("ul.tags.tags--collaborative-draft")
          within "ul.tags.tags--collaborative-draft" do
            expect(page).to have_content(translated(collaborative_draft.scope.name))
          end
        end
      end

      context "when a collaborative draft has comments" do
        let(:author) { create(:user, :confirmed, organization: component.organization) }
        let!(:comments) { create_list(:comment, 3, commentable: collaborative_draft) }

        before do
          visit current_path
        end

        it "shows the comments" do
          comments.each do |comment|
            expect(page).to have_content(comment.body)
          end
        end
      end

      context "when publishing as a proposal" do
        before do
          login_as author, scope: :user
          visit current_path
        end

        it "shows the publish button" do
          within ".view-side" do
            expect(page).to have_css("button", text: "PUBLISH")
          end
        end

        context "when the published" do
          before do
            visit current_path
            click_button "Publish"
          end

          it "shows the a modal" do
            within "#publish-irreversible-action-modal" do
              expect(page).to have_css("h3", text: "The following action is irreversible")
              expect(page).to have_css("button", text: "Publish as a Proposal")
            end
          end

          after do
            click_button "Publish as a Proposal"
          end
        end
      end

      context "when visits a guest user" do
        it "shows an announcement to collaborate" do
          expect(page).to have_css(".callout.secondary")
          within ".callout.secondary" do
            expect(page).to have_css("strong", text: "collaborative draft")
          end
        end
      end

      context "when visits an non author user" do
        before do
          sign_in user, scope: :user
          visit current_path
        end

        it "shows an announcement to collaborate" do
          expect(page).to have_css(".callout.secondary")
          within ".callout.secondary" do
            expect(page).to have_css("strong", text: "collaborative draft")
          end
        end

        it "renders a button to request access" do
          within ".view-side" do
            expect(page).to have_css(".button.expanded.button--sc.mt-s", text: "REQUEST ACCESS")
          end
        end

        context "when the user requests access" do
          before do
            click_button "Request access"
          end

          it "renders an flash informing about the request" do
            expect(page).to have_css(".flash.callout.success")
            within ".flash.callout.success" do
              expect(page).to have_content("Your request to collaborate has been sent successfully")
            end
          end

          it "removes the announcement to collaborate" do
            expect(page).not_to have_css("callout.secondary")
          end

          it "shows that acces has been requested" do
            within ".view-side" do
              expect(page).to have_css(".button.secondary.light.expanded.button--sc.mt-s", text: "ACCESS REQUESTED")
            end
          end

          context "when an author receives the request" do
            before do
              sign_in author, scope: :user
              visit current_path
            end

            it "lists the user in Collaboration Requests" do
              within ".card.extra" do
                expect(page).to have_css("#request_#{user.id}")
              end
            end
            it "shows the button to accept the request" do
              within ".card.extra" do
                expect(page).to have_css(".button.hollow.secondary.small", text: "Accept")
              end
            end
            it "shows the button to reject the request" do
              within ".card.extra" do
                expect(page).to have_css(".icon--x")
              end
            end
          end
        end
      end

      context "when is an author" do
        before do
          sign_in author, scope: :user
          visit current_path
        end

        it "removes the announcement to collaborate" do
          expect(page).not_to have_css("callout.secondary")
        end

        it "shows a button to publish" do
          expect(page).to have_css("#collaborative_draft_publish", text: "PUBLISH")
        end

        it "shows a button to edit" do
          expect(page).to have_css("#collaborative_draft_edit", text: "EDIT COLLABORATIVE DRAFT")
        end
      end
    end
  end

  context "with collaborative drafts disabled" do
    let(:component) { create(:proposal_component, manifest: manifest, participatory_space: participatory_process) }

    before do
      visit main_component_path(component)
    end

    it "does not show the Collaborative drafts acces button" do
      expect(page).to have_no_content("Access collaborative drafts")
    end
  end
end
