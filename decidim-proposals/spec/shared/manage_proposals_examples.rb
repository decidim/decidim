# -*- coding: utf-8 -*-
# frozen_string_literal: true
RSpec.shared_examples "manage proposals" do
  let(:address) { "Carrer Pare Llaurador 113, baixos, 08224 Terrassa" }
  let(:latitude) { 40.1234 }
  let(:longitude) { 2.1234 }

  before do
    Geocoder::Lookup::Test.add_stub(address, [
      { 'latitude' => latitude, 'longitude' => longitude }
    ])
  end

  context "previewing proposals" do
    it "allows the user to preview the proposal" do
      within find("tr", text: proposal.title) do
        @new_window = window_opened_by { find("a.action-icon--preview").click }
      end

      within_window @new_window do
        expect(current_path).to eq decidim_proposals.proposal_path(id: proposal.id, participatory_process_id: participatory_process.id, feature_id: current_feature.id)
        expect(page).to have_content(translated(proposal.title))
      end
    end
  end

  context "creation" do
    context "when official_proposals setting is enabled" do
      before do
        current_feature.settings[:official_proposals_enabled] = true
        current_feature.save
      end

      context "when creation is enabled" do
        before do
          current_feature.update_attributes(
            step_settings: {
              current_feature.participatory_process.active_step.id => {
                creation_enabled: true
              }
            }
          )
        end

        context "when process is not related to any scope" do
          before do
            participatory_process.update_attributes(scope: nil)
          end

          it "can be related to a scope" do
            click_link "New"

            within "form" do
              expect(page).to have_content(/Scope/i)
            end
          end

          it "creates a new proposal" do
            click_link "New"

            within ".new_proposal" do
              fill_in :proposal_title, with: "Make decidim great again"
              fill_in :proposal_body, with: "Decidim is great but it can be better"
              select category.name["en"], from: :proposal_category_id
              select scope.name, from: :proposal_scope_id

              find("*[type=submit]").click
            end

            within ".callout-wrapper" do
              expect(page).to have_content("successfully")
            end

            within "table" do
              proposal = Decidim::Proposals::Proposal.last

              expect(page).to have_content("Make decidim great again")
              expect(proposal.body).to eq("Decidim is great but it can be better")
              expect(proposal.category).to eq(category)
              expect(proposal.scope).to eq(scope)
            end
          end
        end

        context "when process is related to a scope" do
          before do
            participatory_process.update_attributes(scope: scope)
          end

          it "cannot be related to a scope" do
            click_link "New"

            within "form" do
              expect(page).not_to have_content(/Scope/i)
            end
          end

          it "creates a new proposal related to the process scope" do
            click_link "New"

            within ".new_proposal" do
              fill_in :proposal_title, with: "Make decidim great again"
              fill_in :proposal_body, with: "Decidim is great but it can be better"
              select category.name["en"], from: :proposal_category_id
              find("*[type=submit]").click
            end

            within ".callout-wrapper" do
              expect(page).to have_content("successfully")
            end

            within "table" do
              proposal = Decidim::Proposals::Proposal.last

              expect(page).to have_content("Make decidim great again")
              expect(proposal.body).to eq("Decidim is great but it can be better")
              expect(proposal.category).to eq(category)
              expect(proposal.scope).to eq(scope)
            end
          end

          context "when geocoding is enabled" do
            let!(:current_feature) do
              create(:proposal_feature,
                    :with_geocoding_enabled,
                    manifest: manifest,
                    participatory_process: participatory_process)
            end

            it "creates a new proposal related to the process scope" do
              click_link "New"

              within ".new_proposal" do
                fill_in :proposal_title, with: "Make decidim great again"
                fill_in :proposal_body, with: "Decidim is great but it can be better"
                fill_in :proposal_address, with: address
                select category.name["en"], from: :proposal_category_id
                find("*[type=submit]").click
              end

              within ".callout-wrapper" do
                expect(page).to have_content("successfully")
              end

              within "table" do
                proposal = Decidim::Proposals::Proposal.last

                expect(page).to have_content("Make decidim great again")
                expect(proposal.body).to eq("Decidim is great but it can be better")
                expect(proposal.category).to eq(category)
                expect(proposal.scope).to eq(scope)
              end
            end
          end
        end
      end
    end

    context "when official_proposals setting is disabled" do
      before do
        current_feature.update_attributes(settings: { official_proposals_enabled: false } )
      end

      it "cannot create a new proposal" do
        visit_feature
        expect(page).not_to have_content("New Proposal")
      end
    end
  end

  context "when the proposal_answering feature setting is enabled" do
    before do
      current_feature.update_attributes(settings: { proposal_answering_enabled: true } )
    end

    context "when the proposal_answering step setting is enabled" do
      before do
        current_feature.update_attributes(
          step_settings: {
            current_feature.participatory_process.active_step.id => {
              proposal_answering_enabled: true
            }
          }
        )
      end

      it "can reject a proposal" do
        within find("tr", text: proposal.title) do
          find("a.action-icon--edit-answer").click
        end

        within ".edit_proposal_answer" do
          fill_in_i18n_editor(
            :proposal_answer_answer,
            "#answer-tabs",
            en: "The proposal doesn't make any sense",
            es: "La propuesta no tiene sentido",
            ca: "La proposta no te sentit"
          )
          choose "Rejected"
          click_button "Answer"
        end

        within ".callout-wrapper" do
          expect(page).to have_content("Proposal successfully answered")
        end

        within find("tr", text: proposal.title) do
          within find("td:nth-child(4)") do
            expect(page).to have_content("Rejected")
          end
        end
      end

      it "can accept a proposal" do
        within find("tr", text: proposal.title) do
          find("a.action-icon--edit-answer").click
        end

        within ".edit_proposal_answer" do
          choose "Accepted"
          click_button "Answer"
        end

        within ".callout-wrapper" do
          expect(page).to have_content("Proposal successfully answered")
        end

        within find("tr", text: proposal.title) do
          within find("td:nth-child(4)") do
            expect(page).to have_content("Accepted")
          end
        end
      end

      it "can edit a proposal answer" do
        proposal.update_attributes!(
          state: 'rejected',
          answer: {
            'en' => "I don't like it"
          },
          answered_at: Time.current
        )

        visit decidim_admin.manage_feature_path(participatory_process_id: participatory_process, feature_id: current_feature)

        within find("tr", text: proposal.title) do
          within find("td:nth-child(4)") do
            expect(page).to have_content("Rejected")
          end
          find("a.action-icon--edit-answer").click
        end

        within ".edit_proposal_answer" do
          choose "Accepted"
          click_button "Answer"
        end

        within ".callout-wrapper" do
          expect(page).to have_content("Proposal successfully answered")
        end

        within find("tr", text: proposal.title) do
          within find("td:nth-child(4)") do
            expect(page).to have_content("Accepted")
          end
        end
      end
    end

    context "when the proposal_answering step setting is disabled" do
      before do
        current_feature.update_attributes(
          step_settings: {
            current_feature.participatory_process.active_step.id => {
              proposal_answering_enabled: false
            }
          }
        )
      end

      it "cannot answer a proposal" do
        visit current_path

        within find("tr", text: proposal.title) do
          expect(page).to have_no_css("a", text: "Answer")
        end
      end
    end
  end

  context "when the proposal_answering feature setting is disabled" do
    before do
      current_feature.update_attributes(settings: { proposal_answering_enabled: false } )
    end

    it "cannot answer a proposal" do
      visit current_path

      within find("tr", text: proposal.title) do
        expect(page).to have_no_css("a", text: "Answer")
      end
    end
  end
end
