# frozen_string_literal: true

require "spec_helper"

describe "Proposals", type: :feature do
  include_context "feature"
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

  context "listing proposals in a participatory process" do
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

        context "by origin 'official'" do
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

        context "by origin 'citizens'" do
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

      context "by scope" do
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

        context "selecting the global scope" do
          it "lists the filtered proposals" do
            within ".filters" do
              select2("Global scope", xpath: '//select[@id="filter_scope_id"]/..', search: false)
            end

            expect(page).to have_css(".card--proposal", count: 1)
            expect(page).to have_content("1 PROPOSAL")
          end
        end

        context "selecting one scope" do
          it "lists the filtered proposals" do
            within ".filters" do
              select2(translated(scope.name), xpath: '//select[@id="filter_scope_id"]/..', search: true)
            end

            expect(page).to have_css(".card--proposal", count: 2)
            expect(page).to have_content("2 PROPOSALS")
          end
        end

        context "selecting the global scope and another scope" do
          it "lists the filtered proposals" do
            within ".filters" do
              select2(translated(scope.name), xpath: '//select[@id="filter_scope_id"]/..', search: true)
              select2("Global scope", xpath: '//select[@id="filter_scope_id"]/..', search: false)
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

          context "by accepted" do
            it "lists the filtered proposals" do
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
          end

          context "by rejected" do
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
            select category.name[I18n.locale.to_s], from: "filter_category_id"
          end

          expect(page).to have_css(".card--proposal", count: 1)
        end
      end
    end

    context "when ordering" do
      context "by 'most_voted'" do
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

      context "by 'recent'" do
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
    end

    context "when paginating" do
      let!(:collection) { create_list :proposal, collection_size, feature: feature }
      let!(:resource_selector) { ".card--proposal" }

      it_behaves_like "a paginated resource"
    end
  end
end
