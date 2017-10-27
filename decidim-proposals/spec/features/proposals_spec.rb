# frozen_string_literal: true

require "spec_helper"

describe "Proposals", type: :feature do
  include_context "with a feature"
  let(:manifest_name) { "proposals" }

  let!(:category) { create :category, participatory_space: participatory_process }
  let!(:scope) { create :scope, organization: participatory_process.organization }
  let!(:user) { create :user, :confirmed, organization: participatory_process.organization }

  let(:address) { "Carrer Pare Llaurador 113, baixos, 08224 Terrassa" }
  let(:latitude) { 40.1234 }
  let(:longitude) { 2.1234 }

  before do
    Geocoder::Lookup::Test.add_stub(
      address,
      [{ "latitude" => latitude, "longitude" => longitude }]
    )
  end

  context "when creating a new proposal" do
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
          before do
            participatory_process.update_attributes!(scope: nil)
          end

          it "can be related to a scope" do
            visit_feature
            click_link "New proposal"

            within "form.new_proposal" do
              expect(page).to have_content(/Scope/i)
            end
          end
        end

        context "when process is related to any scope" do
          before do
            participatory_process.update_attributes!(scope: scope)
          end

          it "cannot be related to a scope" do
            visit_feature
            click_link "New proposal"

            within "form.new_proposal" do
              expect(page).to have_no_content("Scope")
            end
          end
        end

        it "creates a new proposal" do
          visit_feature

          click_link "New proposal"

          within ".new_proposal" do
            fill_in :proposal_title, with: "Oriol for president"
            fill_in :proposal_body, with: "He will solve everything"
            select translated(category.name), from: :proposal_category_id
            select2 translated(scope.name), from: :proposal_scope_id

            find("*[type=submit]").click
          end

          expect(page).to have_content("successfully")
          expect(page).to have_content("Oriol for president")
          expect(page).to have_content("He will solve everything")
          expect(page).to have_content(translated(category.name))
          expect(page).to have_content(translated(scope.name))
          expect(page).to have_content(user.name)
        end

        context "when geocoding is enabled", :serves_map do
          let!(:feature) do
            create(:proposal_feature,
                   :with_creation_enabled,
                   :with_geocoding_enabled,
                   manifest: manifest,
                   participatory_space: participatory_process)
          end

          it "creates a new proposal" do
            visit_feature

            click_link "New proposal"

            within ".new_proposal" do
              fill_in :proposal_title, with: "Oriol for president"
              fill_in :proposal_body, with: "He will solve everything"

              check :proposal_has_address

              fill_in :proposal_address, with: address
              select translated(category.name), from: :proposal_category_id
              select2 translated(scope.name), from: :proposal_scope_id

              find("*[type=submit]").click
            end

            expect(page).to have_content("successfully")
            expect(page).to have_content("Oriol for president")
            expect(page).to have_content("He will solve everything")
            expect(page).to have_content(address)
            expect(page).to have_content(translated(category.name))
            expect(page).to have_content(translated(scope.name))
            expect(page).to have_content(user.name)
          end
        end

        context "when the user has verified organizations" do
          let(:user_group) { create(:user_group, :verified) }

          before do
            create(:user_group_membership, user: user, user_group: user_group)
          end

          it "creates a new proposal as a user group" do
            visit_feature
            click_link "New proposal"

            within ".new_proposal" do
              fill_in :proposal_title, with: "Oriol for president"
              fill_in :proposal_body, with: "He will solve everything"
              select translated(category.name), from: :proposal_category_id
              select2 translated(scope.name), from: :proposal_scope_id
              select user_group.name, from: :proposal_user_group_id

              find("*[type=submit]").click
            end

            expect(page).to have_content("successfully")
            expect(page).to have_content("Oriol for president")
            expect(page).to have_content("He will solve everything")
            expect(page).to have_content(translated(category.name))
            expect(page).to have_content(translated(scope.name))
            expect(page).to have_content(user_group.name)
          end

          context "when geocoding is enabled", :serves_map do
            let!(:feature) do
              create(:proposal_feature,
                     :with_creation_enabled,
                     :with_geocoding_enabled,
                     manifest: manifest,
                     participatory_space: participatory_process)
            end

            it "creates a new proposal as a user group" do
              visit_feature
              click_link "New proposal"

              within ".new_proposal" do
                fill_in :proposal_title, with: "Oriol for president"
                fill_in :proposal_body, with: "He will solve everything"

                check :proposal_has_address

                fill_in :proposal_address, with: address
                select translated(category.name), from: :proposal_category_id
                select2 translated(scope.name), from: :proposal_scope_id
                select user_group.name, from: :proposal_user_group_id

                find("*[type=submit]").click
              end

              expect(page).to have_content("successfully")
              expect(page).to have_content("Oriol for president")
              expect(page).to have_content("He will solve everything")
              expect(page).to have_content(address)
              expect(page).to have_content(translated(category.name))
              expect(page).to have_content(translated(scope.name))
              expect(page).to have_content(user_group.name)
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

            feature.update_attributes!(permissions: permissions)
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

  context "when viewing a single proposal" do
    let!(:feature) do
      create(:proposal_feature,
             manifest: manifest,
             participatory_space: participatory_process)
    end

    let!(:proposals) { create_list(:proposal, 3, feature: feature) }

    it "allows viewing a single proposal" do
      proposal = proposals.first

      visit_feature

      click_link proposal.title

      expect(page).to have_content(proposal.title)
      expect(page).to have_content(proposal.body)
      expect(page).to have_content(proposal.author.name)
      expect(page).to have_content(proposal.reference)
    end

    context "when process is not related to any scope" do
      let!(:proposal) { create(:proposal, feature: feature, scope: scope) }

      before do
        participatory_process.update_attributes!(scope: nil)
      end

      it "can be filtered by scope" do
        visit_feature
        click_link proposal.title
        expect(page).to have_content(translated(scope.name))
      end
    end

    context "when process is related to a scope" do
      let!(:proposal) { create(:proposal, feature: feature, scope: scope) }

      before do
        participatory_process.update_attributes!(scope: scope)
      end

      it "does not show the scope name" do
        visit_feature
        click_link proposal.title
        expect(page).to have_no_content(translated(scope.name))
      end
    end

    context "when it is an official proposal" do
      let!(:official_proposal) { create(:proposal, feature: feature, author: nil) }

      it "shows the author as official" do
        visit_feature
        click_link official_proposal.title
        expect(page).to have_content("Official proposal")
      end
    end

    context "when a proposal has comments" do
      let(:proposal) { create(:proposal, feature: feature) }
      let(:author) { create(:user, :confirmed, organization: feature.organization) }
      let!(:comments) { create_list(:comment, 3, commentable: proposal) }

      it "shows the comments" do
        visit_feature
        click_link proposal.title

        comments.each do |comment|
          expect(page).to have_content(comment.body)
        end
      end
    end

    context "when a proposal has been linked in a meeting" do
      let(:proposal) { create(:proposal, feature: feature) }
      let(:meeting_feature) do
        create(:feature, manifest_name: :meetings, participatory_space: proposal.feature.participatory_space)
      end
      let(:meeting) { create(:meeting, feature: meeting_feature) }

      before do
        meeting.link_resources([proposal], "proposals_from_meeting")
      end

      it "shows related meetings" do
        visit_feature
        click_link proposal.title

        expect(page).to have_i18n_content(meeting.title)
      end
    end

    context "when a proposal has been linked in a result" do
      let(:proposal) { create(:proposal, feature: feature) }
      let(:dummy_feature) do
        create(:feature, manifest_name: :dummy, participatory_space: proposal.feature.participatory_space)
      end
      let(:dummy_resource) { create(:dummy_resource, feature: dummy_feature) }

      before do
        dummy_resource.link_resources([proposal], "included_proposals")
      end

      it "shows related resources" do
        visit_feature
        click_link proposal.title

        expect(page).to have_i18n_content(dummy_resource.title)
      end
    end

    context "when a proposal is in evaluation" do
      let!(:proposal) { create(:proposal, :evaluating, :with_answer, feature: feature) }

      it "shows a badge and an answer" do
        visit_feature
        click_link proposal.title

        expect(page).to have_content("Evaluating")

        within ".callout.secondary" do
          expect(page).to have_content("This proposal is being evaluated")
          expect(page).to have_i18n_content(proposal.answer)
        end
      end
    end

    context "when a proposal has been rejected" do
      let!(:proposal) { create(:proposal, :rejected, :with_answer, feature: feature) }

      it "shows the rejection reason" do
        visit_feature
        click_link proposal.title

        expect(page).to have_content("Rejected")

        within ".callout.warning" do
          expect(page).to have_content("This proposal has been rejected")
          expect(page).to have_i18n_content(proposal.answer)
        end
      end
    end

    context "when a proposal has been accepted" do
      let!(:proposal) { create(:proposal, :accepted, :with_answer, feature: feature) }

      it "shows the acceptance reason" do
        visit_feature
        click_link proposal.title

        expect(page).to have_content("Accepted")

        within ".callout.success" do
          expect(page).to have_content("This proposal has been accepted")
          expect(page).to have_i18n_content(proposal.answer)
        end
      end
    end

    context "when the proposals'a author account has been deleted" do
      let(:proposal) { proposals.first }

      before do
        Decidim::DestroyAccount.call(proposal.author, Decidim::DeleteAccountForm.from_params({}))
      end

      it "the user is displayed as a deleted user" do
        visit_feature

        click_link proposal.title

        expect(page).to have_content("Deleted user")
      end
    end
  end

  context "when a proposal has been linked in a project" do
    let(:feature) do
      create(:proposal_feature,
             manifest: manifest,
             participatory_space: participatory_process)
    end
    let(:proposal) { create(:proposal, feature: feature) }
    let(:budget_feature) do
      create(:feature, manifest_name: :budgets, participatory_space: proposal.feature.participatory_space)
    end
    let(:project) { create(:project, feature: budget_feature) }

    before do
      project.link_resources([proposal], "included_proposals")
    end

    it "shows related projects" do
      visit_feature
      click_link proposal.title

      expect(page).to have_i18n_content(project.title)
    end
  end

  context "when listing proposals in a participatory process" do
    shared_examples_for "a random proposal ordering" do
      let!(:lucky_proposal) { create(:proposal, feature: feature) }
      let!(:unlucky_proposal) { create(:proposal, feature: feature) }

      it "lists the proposals ordered randomly by default" do
        visit_feature

        expect(page).to have_selector("a", text: "Random")
        expect(page).to have_selector(".card--proposal", count: 2)
        expect(page).to have_selector(".card--proposal", text: lucky_proposal.title)
        expect(page).to have_selector(".card--proposal", text: unlucky_proposal.title)
      end
    end

    it "lists all the proposals" do
      create(:proposal_feature,
             manifest: manifest,
             participatory_space: participatory_process)

      create_list(:proposal, 3, feature: feature)

      visit_feature
      expect(page).to have_css(".card--proposal", count: 3)
    end

    describe "default ordering" do
      it_behaves_like "a random proposal ordering"
    end

    context "when voting phase is over" do
      let!(:feature) do
        create(:proposal_feature,
               :with_votes_blocked,
               manifest: manifest,
               participatory_space: participatory_process)
      end

      let!(:most_voted_proposal) do
        proposal = create(:proposal, feature: feature)
        create_list(:proposal_vote, 3, proposal: proposal)
        proposal
      end

      let!(:less_voted_proposal) { create(:proposal, feature: feature) }

      before { visit_feature }

      it "lists the proposals ordered by votes by default" do
        expect(page).to have_selector("a", text: "Most voted")
        expect(page).to have_selector("#proposals .card-grid .column:first-child", text: most_voted_proposal.title)
        expect(page).to have_selector("#proposals .card-grid .column:last-child", text: less_voted_proposal.title)
      end

      it "shows a disabled vote button for each proposal, but no links to full proposals" do
        expect(page).to have_button("Voting disabled", disabled: true, count: 2)
        expect(page).to have_no_link("View proposal")
      end
    end

    context "when voting is disabled" do
      let!(:feature) do
        create(:proposal_feature,
               :with_votes_disabled,
               manifest: manifest,
               participatory_space: participatory_process)
      end

      describe "order" do
        it_behaves_like "a random proposal ordering"
      end

      it "shows only links to full proposals" do
        create_list(:proposal, 2, feature: feature)

        visit_feature

        expect(page).to have_no_button("Voting disabled", disabled: true)
        expect(page).to have_no_button("Vote")
        expect(page).to have_link("View proposal", count: 2)
      end
    end

    context "when there are a lot of proposals" do
      before do
        create_list(:proposal, Decidim::Paginable::OPTIONS.first + 5, feature: feature)
      end

      it "paginates them" do
        visit_feature

        expect(page).to have_css(".card--proposal", count: Decidim::Paginable::OPTIONS.first)

        click_link "Next"

        expect(page).to have_selector(".pagination .current", text: "2")

        expect(page).to have_css(".card--proposal", count: 5)
      end
    end

    context "when filtering" do
      context "when official_proposals setting is enabled" do
        before do
          feature.update_attributes!(settings: { official_proposals_enabled: true })
        end

        it "can be filtered by origin" do
          visit_feature

          within "form.new_filter" do
            expect(page).to have_content(/Origin/i)
          end
        end

        context "with 'official' origin" do
          it "lists the filtered proposals" do
            create_list(:proposal, 2, :official, feature: feature, scope: scope)
            create(:proposal, feature: feature, scope: scope)
            visit_feature

            within ".filters" do
              choose "Official"
            end

            expect(page).to have_css(".card--proposal", count: 2)
            expect(page).to have_content("2 PROPOSALS")
          end
        end

        context "with 'citizens' origin" do
          it "lists the filtered proposals" do
            create_list(:proposal, 2, feature: feature, scope: scope)
            create(:proposal, :official, feature: feature, scope: scope)
            visit_feature

            within ".filters" do
              choose "Citizens"
            end

            expect(page).to have_css(".card--proposal", count: 2)
            expect(page).to have_content("2 PROPOSALS")
          end
        end
      end

      context "when official_proposals setting is not enabled" do
        before do
          feature.update_attributes!(settings: { official_proposals_enabled: false })
        end

        it "cannot be filtered by origin" do
          visit_feature

          within "form.new_filter" do
            expect(page).to have_no_content(/Origin/i)
          end
        end
      end

      context "with scope" do
        let!(:scope2) { create :scope, organization: participatory_process.organization }

        before do
          create_list(:proposal, 2, feature: feature, scope: scope)
          create(:proposal, feature: feature, scope: scope2)
          create(:proposal, feature: feature, scope: nil)
          visit_feature
        end

        it "can be filtered by scope" do
          within "form.new_filter" do
            expect(page).to have_content(/Scopes/i)
          end
        end

        context "when selecting the global scope" do
          it "lists the filtered proposals" do
            within ".filters" do
              select2("Global scope", from: :filter_scope_id)
            end

            expect(page).to have_css(".card--proposal", count: 1)
            expect(page).to have_content("1 PROPOSAL")
          end
        end

        context "when selecting one scope" do
          it "lists the filtered proposals" do
            within ".filters" do
              select2(translated(scope.name), from: :filter_scope_id)
            end

            expect(page).to have_css(".card--proposal", count: 2)
            expect(page).to have_content("2 PROPOSALS")
          end
        end

        context "when selecting the global scope and another scope" do
          it "lists the filtered proposals" do
            within ".filters" do
              select2(translated(scope.name), from: :filter_scope_id)
              select2("Global scope", from: :filter_scope_id)
            end

            expect(page).to have_css(".card--proposal", count: 3)
            expect(page).to have_content("3 PROPOSALS")
          end
        end
      end

      context "when process is related to a scope" do
        before do
          participatory_process.update_attributes!(scope: scope)
        end

        it "cannot be filtered by scope" do
          visit_feature

          within "form.new_filter" do
            expect(page).to have_no_content(/Scopes/i)
          end
        end
      end

      context "when proposal_answering feature setting is enabled" do
        before do
          feature.update_attributes!(settings: { proposal_answering_enabled: true })
        end

        context "when proposal_answering step setting is enabled" do
          before do
            feature.update_attributes!(
              step_settings: {
                feature.participatory_space.active_step.id => {
                  proposal_answering_enabled: true
                }
              }
            )
          end

          it "can be filtered by state" do
            visit_feature

            within "form.new_filter" do
              expect(page).to have_content(/State/i)
            end
          end

          it "lists accepted proposals" do
            create(:proposal, :accepted, feature: feature, scope: scope)
            visit_feature

            within ".filters" do
              choose "Accepted"
            end

            expect(page).to have_css(".card--proposal", count: 1)
            expect(page).to have_content("1 PROPOSAL")

            within ".card--proposal" do
              expect(page).to have_content("Accepted")
            end
          end

          it "lists the filtered proposals" do
            create(:proposal, :rejected, feature: feature, scope: scope)
            visit_feature

            within ".filters" do
              choose "Rejected"
            end

            expect(page).to have_css(".card--proposal", count: 1)
            expect(page).to have_content("1 PROPOSAL")

            within ".card--proposal" do
              expect(page).to have_content("Rejected")
            end
          end
        end

        context "when proposal_answering step setting is disabled" do
          before do
            feature.update_attributes!(
              step_settings: {
                feature.participatory_space.active_step.id => {
                  proposal_answering_enabled: false
                }
              }
            )
          end

          it "cannot be filtered by state" do
            visit_feature

            within "form.new_filter" do
              expect(page).to have_no_content(/State/i)
            end
          end
        end
      end

      context "when proposal_answering feature setting is not enabled" do
        before do
          feature.update_attributes!(settings: { proposal_answering_enabled: false })
        end

        it "cannot be filtered by state" do
          visit_feature

          within "form.new_filter" do
            expect(page).to have_no_content(/State/i)
          end
        end
      end

      context "when the user is logged in" do
        before do
          login_as user, scope: :user
        end

        it "can be filtered by category" do
          create_list(:proposal, 3, feature: feature)
          create(:proposal, feature: feature, category: category)

          visit_feature

          within "form.new_filter" do
            select category.name[I18n.locale.to_s], from: :filter_category_id
          end

          expect(page).to have_css(".card--proposal", count: 1)
        end
      end
    end

    context "when ordering by 'most_voted'" do
      let!(:feature) do
        create(:proposal_feature,
               :with_votes_enabled,
               manifest: manifest,
               participatory_space: participatory_process)
      end

      it "lists the proposals ordered by votes" do
        most_voted_proposal = create(:proposal, feature: feature)
        create_list(:proposal_vote, 3, proposal: most_voted_proposal)
        less_voted_proposal = create(:proposal, feature: feature)

        visit_feature

        within ".order-by" do
          expect(page).to have_selector("ul[data-dropdown-menu$=dropdown-menu]", text: "Random")
          page.find("a", text: "Random").click
          click_link "Most voted"
        end

        expect(page).to have_selector("#proposals .card-grid .column:first-child", text: most_voted_proposal.title)
        expect(page).to have_selector("#proposals .card-grid .column:last-child", text: less_voted_proposal.title)
      end
    end

    context "when ordering by 'recent'" do
      it "lists the proposals ordered by created at" do
        older_proposal = create(:proposal, feature: feature, created_at: 1.month.ago)
        recent_proposal = create(:proposal, feature: feature)

        visit_feature

        within ".order-by" do
          expect(page).to have_selector("ul[data-dropdown-menu$=dropdown-menu]", text: "Random")
          page.find("a", text: "Random").click
          click_link "Recent"
        end

        expect(page).to have_selector("#proposals .card-grid .column:first-child", text: recent_proposal.title)
        expect(page).to have_selector("#proposals .card-grid .column:last-child", text: older_proposal.title)
      end
    end

    context "when paginating" do
      let!(:collection) { create_list :proposal, collection_size, feature: feature }
      let!(:resource_selector) { ".card--proposal" }

      it_behaves_like "a paginated resource"
    end
  end
end
