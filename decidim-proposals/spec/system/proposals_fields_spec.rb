# frozen_string_literal: true

require "spec_helper"

describe "Proposals", type: :system do
  include_context "with a feature"
  let(:manifest_name) { "proposals" }

  let!(:category) { create :category, participatory_space: participatory_process }
  let!(:scope) { create :scope, organization: organization }
  let!(:user) { create :user, :confirmed, organization: organization }
  let(:scoped_participatory_process) { create(:participatory_process, :with_steps, organization: organization, scope: scope) }

  let(:address) { "Carrer Pare Llaurador 113, baixos, 08224 Terrassa" }
  let(:latitude) { 40.1234 }
  let(:longitude) { 2.1234 }

  before do
    Geocoder::Lookup::Test.add_stub(
      address,
      [{ "latitude" => latitude, "longitude" => longitude }]
    )
  end

  matcher :have_author do |name|
    match { |node| node.has_selector?(".author-data", text: name) }
    match_when_negated { |node| node.has_no_selector?(".author-data", text: name) }
  end

  context "when creating a new proposal" do
    let(:scope_picker) { scopes_picker_find(:proposal_scope_id) }

    context "when the user is logged in" do
      before do
        login_as user, scope: :user
      end

      context "with creation enabled" do
        let!(:feature) do
          create(:proposal_feature,
                 :with_creation_enabled,
                 manifest: manifest,
                 participatory_space: participatory_process)
        end

        context "when process is not related to any scope" do
          it "can be related to a scope" do
            visit_feature
            click_link "New proposal"

            within "form.new_proposal" do
              expect(page).to have_content(/Scope/i)
            end
          end
        end

        context "when process is related to a leaf scope" do
          let(:participatory_process) { scoped_participatory_process }

          it "cannot be related to a scope" do
            visit_feature
            click_link "New proposal"

            within "form.new_proposal" do
              expect(page).to have_no_content("Scope")
            end
          end
        end

        it "creates a new proposal", :slow do
          visit_feature

          click_link "New proposal"

          within ".new_proposal" do
            fill_in :proposal_title, with: "Oriol for president"
            fill_in :proposal_body, with: "He will solve everything"
            select translated(category.name), from: :proposal_category_id
            scope_pick scope_picker, scope

            find("*[type=submit]").click
          end

          click_button "Publish"

          expect(page).to have_content("successfully")
          expect(page).to have_content("Oriol for president")
          expect(page).to have_content("He will solve everything")
          expect(page).to have_content(translated(category.name))
          expect(page).to have_content(translated(scope.name))
          expect(page).to have_author(user.name)
        end

        context "when geocoding is enabled", :serves_map do
          let!(:feature) do
            create(:proposal_feature,
                   :with_creation_enabled,
                   :with_geocoding_enabled,
                   manifest: manifest,
                   participatory_space: participatory_process)
          end

          it "creates a new proposal", :slow do
            create(:proposal, feature: feature, title: "Homer for president", body: "He will not solve everything")

            visit_feature

            click_link "New proposal"

            within ".new_proposal" do
              fill_in :proposal_title, with: "Oriol for president"
              fill_in :proposal_body, with: "He will solve everything"

              check :proposal_has_address

              fill_in :proposal_address, with: address
              select translated(category.name), from: :proposal_category_id
              scope_pick scope_picker, scope

              find("*[type=submit]").click
            end

            click_link "My proposal is different"

            click_button "Publish"

            expect(page).to have_content("successfully")
            expect(page).to have_content("Oriol for president")
            expect(page).to have_content("He will solve everything")
            expect(page).to have_content(address)
            expect(page).to have_content(translated(category.name))
            expect(page).to have_content(translated(scope.name))
            expect(page).to have_author(user.name)
          end
        end

        context "when the user has verified organizations" do
          let(:user_group) { create(:user_group, :verified) }

          before do
            create(:user_group_membership, user: user, user_group: user_group)
          end

          it "creates a new proposal as a user group", :slow do
            visit_feature
            click_link "New proposal"

            within ".new_proposal" do
              fill_in :proposal_title, with: "Oriol for president"
              fill_in :proposal_body, with: "He will solve everything"
              select translated(category.name), from: :proposal_category_id
              scope_pick scope_picker, scope
              select user_group.name, from: :proposal_user_group_id

              find("*[type=submit]").click
            end

            click_button "Publish"

            expect(page).to have_content("successfully")
            expect(page).to have_content("Oriol for president")
            expect(page).to have_content("He will solve everything")
            expect(page).to have_content(translated(category.name))
            expect(page).to have_content(translated(scope.name))
            expect(page).to have_author(user_group.name)
          end

          context "when geocoding is enabled", :serves_map do
            let!(:feature) do
              create(:proposal_feature,
                     :with_creation_enabled,
                     :with_geocoding_enabled,
                     manifest: manifest,
                     participatory_space: participatory_process)
            end

            it "creates a new proposal as a user group", :slow do
              create(:proposal, feature: feature, title: "Homer for president", body: "He will not solve everything")

              visit_feature
              click_link "New proposal"

              within ".new_proposal" do
                fill_in :proposal_title, with: "Oriol for president"
                fill_in :proposal_body, with: "He will solve everything"

                check :proposal_has_address

                fill_in :proposal_address, with: address
                select translated(category.name), from: :proposal_category_id
                scope_pick scope_picker, scope
                select user_group.name, from: :proposal_user_group_id

                find("*[type=submit]").click
              end

              click_link "My proposal is different"

              click_button "Publish"

              expect(page).to have_content("successfully")
              expect(page).to have_content("Oriol for president")
              expect(page).to have_content("He will solve everything")
              expect(page).to have_content(address)
              expect(page).to have_content(translated(category.name))
              expect(page).to have_content(translated(scope.name))
              expect(page).to have_author(user_group.name)
            end
          end
        end

        context "when the user isn't authorized" do
          before do
            permissions = {
              create: {
                authorization_handler_name: "dummy_authorization_handler"
              }
            }

            feature.update!(permissions: permissions)
          end

          it "shows a modal dialog" do
            visit_feature
            click_link "New proposal"
            expect(page).to have_content("Authorization required")
          end
        end

        context "when attachments are allowed", processing_uploads_for: Decidim::AttachmentUploader do
          let!(:feature) do
            create(:proposal_feature,
                   :with_creation_enabled,
                   :with_attachments_allowed,
                   manifest: manifest,
                   participatory_space: participatory_process)
          end

          it "creates a new proposal with attachments" do
            visit_feature

            click_link "New proposal"

            within ".new_proposal" do
              fill_in :proposal_title, with: "Proposal with attachments"
              fill_in :proposal_body, with: "This is my proposal and I want to upload attachments."
              fill_in :proposal_attachment_title, with: "My attachment"
              attach_file :proposal_attachment_file, Decidim::Dev.asset("city.jpeg")
              find("*[type=submit]").click
            end

            click_button "Publish"

            expect(page).to have_content("successfully")

            within ".section.images" do
              expect(page).to have_selector("img[src*=\"city.jpeg\"]", count: 1)
            end
          end
        end
      end

      context "when creation is not enabled" do
        it "does not show the creation button" do
          visit_feature
          expect(page).to have_no_link("New proposal")
        end
      end

      context "when the proposal limit is 1" do
        let!(:feature) do
          create(:proposal_feature,
                 :with_creation_enabled,
                 :with_proposal_limit,
                 manifest: manifest,
                 participatory_space: participatory_process)
        end

        it "allows the creation of a single new proposal" do
          visit_feature

          click_link "New proposal"
          within ".new_proposal" do
            fill_in :proposal_title, with: "Creating my first and only proposal"
            fill_in :proposal_body, with: "This is my only proposal's body and I'm using it unwisely."
            find("*[type=submit]").click
          end

          click_button "Publish"

          expect(page).to have_content("successfully")

          visit_feature

          click_link "New proposal"
          within ".new_proposal" do
            fill_in :proposal_title, with: "Creating my second and impossible proposal"
            fill_in :proposal_body, with: "This is my only proposal's body and I'm using it unwisely."
            find("*[type=submit]").click
          end

          expect(page).to have_no_content("successfully")
          expect(page).to have_css(".callout.alert", text: "limit")
        end
      end
    end
  end
end
