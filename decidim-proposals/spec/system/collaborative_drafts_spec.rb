# frozen_string_literal: true

require "spec_helper"

describe "Explore Collaborative Drafts", versioning: true, type: :system do
  include Decidim::Proposals::ApplicationHelper
  include ActionView::Helpers::TextHelper

  include_context "with a component"

  let(:manifest_name) { "proposals" }
  let!(:scope) { create :scope, organization: }
  let!(:author) { create :user, :confirmed, organization: }
  let!(:user) { create :user, :confirmed, organization: }
  let(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
  let!(:component) do
    create(:proposal_component,
           :with_creation_enabled,
           manifest:,
           participatory_space: participatory_process,
           organization:,
           settings: {
             collaborative_drafts_enabled: true,
             scopes_enabled: true,
             scope_id: participatory_process.scope&.id
           })
  end
  let!(:category) { create :category, participatory_space: participatory_process }
  let!(:category2) { create :category, participatory_space: participatory_process }
  let!(:category3) { create :category, participatory_space: participatory_process }
  let!(:collaborative_draft) { create(:collaborative_draft, :open, component:, category:, scope:, users: [author]) }
  let!(:collaborative_draft_no_tags) { create(:collaborative_draft, :open, component:) }

  let!(:open_collaborative_draft) { create(:collaborative_draft, :open, component:, category:) }
  let!(:withdrawn_collaborative_draft) { create(:collaborative_draft, :withdrawn, component:, category: category2) }
  let!(:published_collaborative_draft) { create(:collaborative_draft, :published, component:, category: category3) }

  let(:request_access_form) { Decidim::Proposals::RequestAccessToCollaborativeDraftForm.from_params(state: collaborative_draft.state, id: collaborative_draft.id) }
  let!(:other_user) { create :user, :confirmed, organization: }
  let(:request_access_from_other_user) { Decidim::Proposals::RequestAccessToCollaborativeDraft.new(request_access_form, other_user) }

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
          expect(find(:css, "input[name='filter[with_any_state][]'][value='open']")).to be_checked
        end
      end

      it "renders links to each collaborative draft details" do
        collaborative_drafts_count = Decidim::Proposals::CollaborativeDraft.open.where(component:).count
        expect(page).to have_css(".card.card--collaborative_draft.success", count: collaborative_drafts_count)
        expect(page).to have_css(".card__button.button", count: collaborative_drafts_count)
        first ".card__support" do
          expect(page).to have_css(".card__button.button", text: "VIEW COLLABORATIVE DRAFT")
        end
      end

      it "shows state filters" do
        within ".filters .with_any_state_check_boxes_tree_filter" do
          expect(page).to have_field("All")
          expect(page).to have_field("Open")
          expect(page).to have_field("Withdrawn")
          expect(page).to have_field("Published")
        end
      end

      it "shows category filters" do
        within ".filters .with_any_category_check_boxes_tree_filter" do
          expect(page).to have_field("All")
          [category, category2, category3].each do |cat|
            expect(page).to have_field(cat.name[I18n.locale.to_s])
          end
        end
      end
    end

    describe "renders collaborative draft details" do
      before do
        within "#collaborative_draft_#{collaborative_draft.id}" do
          click_link "View Collaborative Draft"
        end
      end

      let(:html_body) { strip_tags(collaborative_draft.body).gsub(/\n/, " ").strip }
      let(:stripped_body) { %(alert("BODY"); #{html_body}) }

      it "shows the title" do
        expect(page).to have_content(collaborative_draft.title)
      end

      it "shows the body" do
        expect(page).to have_content(stripped_body)
      end

      it "shows the state" do
        expect(page).to have_css(".label.collaborative-draft-status", text: "Open")
      end

      context "when geocoding is enabled" do
        let!(:component) do
          create(:proposal_component,
                 :with_creation_enabled,
                 manifest:,
                 participatory_space: participatory_process,
                 organization:,
                 settings: {
                   collaborative_drafts_enabled: true,
                   geocoding_enabled: true,
                   scopes_enabled: true,
                   scope_id: participatory_process.scope&.id
                 })
        end
        let!(:collaborative_draft) { create(:collaborative_draft, :open, component:, address:, category:, scope:, users: [author]) }
        let(:address) { "Some address" }
        let(:latitude) { 40.1234 }
        let(:longitude) { 2.1234 }

        before do
          stub_geocoding(address, [latitude, longitude])
        end

        it "shows the title" do
          expect(page).to have_content(collaborative_draft.title)
        end

        it "shows the body" do
          expect(page).to have_content(stripped_body)
        end

        it "shows the address" do
          expect(page).to have_content(collaborative_draft.address)
        end
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
            expect(page).to have_content(comment.body.values.first)
          end
        end
      end

      context "when publishing as a proposal" do
        before do
          within ".view-header" do
            expect(page).to have_content(collaborative_draft.title)
          end
          login_as author, scope: :user
          visit current_path
          within ".header .title-bar .topbar__user__logged" do
            expect(page).to have_content(author.name)
          end
        end

        it "shows the publish button" do
          within ".view-side" do
            expect(page).to have_css("button", text: "PUBLISH")
          end
        end

        context "when the publish button is clicked" do
          before do
            click_button "Publish"
          end

          it "shows the a modal" do
            within "[id$='publish-irreversible-action-modal'" do
              expect(page).to have_css("h3", text: "The following action is irreversible")
              expect(page).to have_css("button", text: "Publish as a Proposal")
            end
            click_button "Publish as a Proposal"
            expect(page).to have_content("Collaborative draft published successfully as a proposal.")
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
          within ".view-header" do
            expect(page).to have_content(collaborative_draft.title)
          end
          login_as user, scope: :user
          visit current_path
          within ".header .title-bar .topbar__user__logged" do
            expect(page).to have_content(user.name)
          end
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
            expect(page).to have_button("Access requested")
          end

          it "renders an flash informing about the request" do
            expect(page).to have_css("[data-alert-box].success")
            within "[data-alert-box].success" do
              expect(page).to have_content("Your request to collaborate has been successfully sent")
            end
          end

          it "removes the announcement to collaborate" do
            expect(page).not_to have_css("[data-alert-box].secondary")
          end

          it "shows that access has been requested" do
            within ".view-side" do
              expect(page).to have_css(".button.expanded.button--sc.mt-s", text: "ACCESS REQUESTED")
            end
          end

          context "when the author receives the request" do
            before do
              relogin_as author, scope: :user
              visit current_path
              within ".header .title-bar .topbar__user__logged" do
                expect(page).to have_content(author.name)
              end
            end

            it "lists the user in Collaboration Requests" do
              within ".card.extra" do
                expect(page).to have_content("COLLABORATION REQUESTS")
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
                expect(page).to have_button("Reject")
              end
            end

            context "when the request is accepted and the contributor visits the draft" do
              before do
                click_button "Accept"
                expect(page).to have_content("@#{user.nickname} has been accepted as a collaborator successfully")
                relogin_as user, scope: :user
                visit current_path
                within ".header .title-bar .topbar__user__logged" do
                  expect(page).to have_content(user.name)
                end
              end

              it "shows the user as a coauthor" do
                expect(page).to have_css("#content .wrapper .author--inline .author-data .author__name", text: user.name)
              end

              it "removes the announcement to collaborate" do
                expect(page).not_to have_css("callout.secondary")
              end

              it "does not show the buttons to publish or withdraw" do
                expect(page).not_to have_button("Publish")
                expect(page).not_to have_button("withdraw the draft")
              end

              it "shows a button to edit" do
                expect(page).to have_css("#collaborative_draft_edit", text: "EDIT COLLABORATIVE DRAFT")
              end

              it "does not show the Collaboration Requests from other users" do
                request_access_from_other_user.call
                visit current_path

                expect(page).not_to have_content("COLLABORATION REQUESTS")
              end
            end
          end
        end
      end

      context "when the author visits the collaborative draft" do
        before do
          within ".view-header" do
            expect(page).to have_content(collaborative_draft.title)
          end
          login_as author, scope: :user
          visit current_path
          within ".header .title-bar .topbar__user__logged" do
            expect(page).to have_content(author.name)
          end
        end

        it "removes the announcement to collaborate" do
          expect(page).not_to have_css("callout.secondary")
        end

        it "shows the buttons to publish or withdraw" do
          expect(page).to have_button("Publish")
          expect(page).to have_button("withdraw the draft")
        end

        it "shows a button to edit" do
          expect(page).to have_css("#collaborative_draft_edit", text: "EDIT COLLABORATIVE DRAFT")
        end
      end
    end
  end

  context "with collaborative drafts disabled" do
    let(:component) { create(:proposal_component, manifest:, participatory_space: participatory_process) }

    before do
      visit main_component_path(component)
    end

    it "does not show the Collaborative drafts access button" do
      expect(page).not_to have_content("Access collaborative drafts")
    end
  end
end
