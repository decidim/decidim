# frozen_string_literal: true

require "spec_helper"

describe "Explore Collaborative Drafts", versioning: true do
  include Decidim::Proposals::ApplicationHelper
  include ActionView::Helpers::TextHelper

  include_context "with a component"

  let(:manifest_name) { "proposals" }
  let!(:author) { create(:user, :confirmed, organization:) }
  let!(:user) { create(:user, :confirmed, organization:) }
  let(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
  let!(:component) do
    create(:proposal_component,
           :with_creation_enabled,
           manifest:,
           participatory_space: participatory_process,
           organization:,
           settings: {
             collaborative_drafts_enabled: true,
             taxonomy_filters: [taxonomy_filter.id]
           })
  end
  let(:root_taxonomy) { create(:taxonomy, organization:) }
  let!(:taxonomy) { create(:taxonomy, skip_injection: true, parent: root_taxonomy, organization:) }
  let!(:taxonomy2) { create(:taxonomy, skip_injection: true, parent: root_taxonomy, organization:) }
  let!(:taxonomy3) { create(:taxonomy, skip_injection: true, parent: root_taxonomy, organization:) }
  let(:taxonomies) { [taxonomy] }
  let(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:) }
  let!(:taxonomy_filter_item2) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: taxonomy2) }
  let!(:taxonomy_filter_item3) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: taxonomy3) }
  let!(:collaborative_draft) { create(:collaborative_draft, :open, component:, taxonomies:, users: [author]) }
  let!(:collaborative_draft_no_tags) { create(:collaborative_draft, :open, component:) }

  let!(:open_collaborative_draft) { create(:collaborative_draft, :open, component:, taxonomies:) }
  let!(:withdrawn_collaborative_draft) { create(:collaborative_draft, :withdrawn, component:, taxonomies: [taxonomy2]) }
  let!(:published_collaborative_draft) { create(:collaborative_draft, :published, component:, taxonomies: [taxonomy3]) }

  let(:request_access_form) { Decidim::Proposals::RequestAccessToCollaborativeDraftForm.from_params(state: collaborative_draft.state, id: collaborative_draft.id) }
  let!(:other_user) { create(:user, :confirmed, organization:) }
  let(:request_access_from_other_user) { Decidim::Proposals::RequestAccessToCollaborativeDraft.new(request_access_form, other_user) }

  let(:selector) { '[id^="proposals__collaborative_draft"]' }

  context "with collaborative drafts enabled" do
    before do
      visit main_component_path(component)
      click_on "Access collaborative drafts"
    end

    describe "Renders collaborative drafts index" do
      it "shows Open Drafts by default" do
        first ".card__list" do
          expect(page).to have_css(".label.success", text: "Open")
        end
        within "#dropdown-menu-filters" do
          expect(find(:css, "input[name='filter[with_any_state][]'][value='open']")).to be_checked
        end
      end

      it "renders links to each collaborative draft details" do
        collaborative_drafts_count = Decidim::Proposals::CollaborativeDraft.open.where(component:).count
        expect(page).to have_css(selector, count: collaborative_drafts_count)
      end

      it "shows state filters" do
        within "[data-filters]" do
          expect(page).to have_field("All")
          expect(page).to have_field("Open")
          expect(page).to have_field("Withdrawn")
          expect(page).to have_field("Published")
        end
      end

      it "shows taxonomy filters" do
        within "[data-filters]" do
          expect(page).to have_field("All")
          [taxonomy, taxonomy2, taxonomy3].each do |tax|
            expect(page).to have_field(decidim_sanitize_translated(tax.name))
          end
        end
      end
    end

    describe "renders collaborative draft details" do
      before do
        click_on "proposals__collaborative_draft_#{collaborative_draft.id}"
      end

      let(:html_body) { strip_tags(collaborative_draft.body).gsub(/\n/, " ").strip }
      let(:stripped_body) { %(alert("collaborative_draft_body"); #{html_body}) }

      it "shows the title" do
        expect(page).to have_content(collaborative_draft.title)
      end

      it "shows the body" do
        expect(page).to have_content(stripped_body)
      end

      it "shows the state" do
        expect(page).to have_css(".label", text: "Open")
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
                   geocoding_enabled: true
                 })
        end
        let!(:collaborative_draft) { create(:collaborative_draft, :open, component:, address:, taxonomies:, users: [author]) }
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

      context "without taxonomies" do
        before do
          visit_component
          click_on "Access collaborative drafts"
          click_on "proposals__collaborative_draft_#{collaborative_draft_no_tags.id}"
        end

        it "does not show any tag" do
          expect(page).to have_no_selector("ul.tags")
        end
      end

      context "with a taxonomy" do
        it "shows tags for taxonomy" do
          expect(page).to have_css("ul.tag-container")
          within "ul.tag-container" do
            expect(page).to have_content(decidim_sanitize_translated(taxonomy.name))
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
          within "main" do
            expect(page).to have_content(collaborative_draft.title)
          end
          login_as author, scope: :user
          sleep(1)
          visit current_path
          within ".main-bar__links-desktop" do
            expect(page).to have_css("#trigger-dropdown-account")
          end
        end

        it "shows the publish button" do
          expect(page).to have_button(text: "Publish")
        end

        context "when the publish button is clicked" do
          before do
            click_on "Publish"
          end

          it "shows the a modal" do
            within "[id$='publish-irreversible-action-modal'][aria-modal]" do
              expect(page).to have_css("h3", text: "The following action is irreversible")
              expect(page).to have_button(text: "Publish as a Proposal")
            end
            click_on "Publish as a Proposal"
            expect(page).to have_content("Collaborative draft published successfully as a proposal.")
          end
        end
      end

      context "when visits a guest user" do
        it "shows an announcement to collaborate" do
          within "[data-announcement]" do
            expect(page).to have_css("strong", text: "collaborative draft")
          end
        end
      end

      context "when visits an non author user" do
        before do
          within "main" do
            expect(page).to have_content(collaborative_draft.title)
          end
          login_as user, scope: :user
          sleep(1)
          visit current_path
          within ".main-bar__links-desktop" do
            expect(page).to have_css("#trigger-dropdown-account")
          end
        end

        it "shows an announcement to collaborate" do
          within "[data-announcement]" do
            expect(page).to have_css("strong", text: "collaborative draft")
          end
        end

        it "renders a button to request access" do
          expect(page).to have_button(text: "Request access")
        end

        context "when the user requests access" do
          before do
            click_on "Request access"
            expect(page).to have_button("Access requested", disabled: true)
          end

          it "renders an flash informing about the request" do
            expect(page).to have_css("[data-alert-box].success")
            within "[data-alert-box].success" do
              expect(page).to have_content("Your request to collaborate has been successfully sent")
            end
          end

          it "removes the announcement to collaborate" do
            expect(page).to have_no_css("[data-alert-box].secondary")
          end

          it "shows that access has been requested" do
            expect(page).to have_css("button[disabled]", text: "Access requested")
          end

          context "when the author receives the request" do
            before do
              within ".main-bar__links-desktop" do
                expect(page).to have_css("#trigger-dropdown-account")
              end
              relogin_as author, scope: :user
              visit current_path
              within ".main-bar__links-desktop" do
                expect(page).to have_css("#trigger-dropdown-account")
              end
            end

            it "lists the user in Collaboration Requests" do
              expect(page).to have_content("Collaboration requests")
              expect(page).to have_css("#request_#{user.id}")
            end

            it "shows the button to accept the request" do
              expect(page).to have_button(text: "Accept")
            end

            it "shows the button to reject the request" do
              expect(page).to have_button("Reject")
            end

            context "when the request is accepted and the contributor visits the draft" do
              before do
                click_on "Accept"
                expect(page).to have_content("@#{user.nickname} has been accepted as a collaborator successfully")
                relogin_as user, scope: :user
                visit current_path
                expect(page).to have_css("span.main-bar__avatar")
              end

              it "shows the user as a coauthor" do
                expect(page).to have_css("#content div.author__coauthors .author__name", text: user.name)
              end

              it "removes the announcement to collaborate" do
                expect(page).to have_no_css("#new_accept_access_to_collaborative_draft_")
                expect(page).to have_no_css("#new_reject_access_to_collaborative_draft_")
              end

              it "does not show the buttons to publish or withdraw" do
                expect(page).to have_no_button("Publish")
                expect(page).to have_no_button("withdraw the draft")
              end

              it "shows a button to edit" do
                find("#dropdown-trigger-resource-#{collaborative_draft.id}").click
                expect(page).to have_css("#collaborative_draft_edit", text: "Edit")
              end

              it "does not show the Collaboration Requests from other users" do
                request_access_from_other_user.call
                visit current_path

                expect(page).to have_no_content("Collaboration requests")
              end
            end
          end
        end
      end

      context "when the author visits the collaborative draft" do
        before do
          within "main" do
            expect(page).to have_content(collaborative_draft.title)
          end
          login_as author, scope: :user
          sleep(1)
          visit current_path
          within ".main-bar__links-desktop" do
            expect(page).to have_css("#trigger-dropdown-account")
          end
        end

        it "removes the announcement to collaborate" do
          expect(page).to have_no_css("callout")
        end

        it "shows the buttons to publish or withdraw" do
          expect(page).to have_button("Publish")
          expect(page).to have_button("withdraw the draft")
        end

        it "shows a button to edit" do
          find("#dropdown-trigger-resource-#{collaborative_draft.id}").click
          expect(page).to have_css("#collaborative_draft_edit", text: "Edit")
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
      expect(page).to have_no_content("Access collaborative drafts")
    end
  end
end
