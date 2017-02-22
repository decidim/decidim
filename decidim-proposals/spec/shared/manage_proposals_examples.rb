# -*- coding: utf-8 -*-
# frozen_string_literal: true
RSpec.shared_examples "manage proposals" do
  context "previewing proposals" do
    it "allows the user to preview the proposal" do
      new_window = window_opened_by { click_link proposal.title }

      within_window new_window do
        expect(current_path).to eq decidim_proposals.proposal_path(id: proposal.id, participatory_process_id: participatory_process.id, feature_id: current_feature.id)
        expect(page).to have_content(translated(proposal.title))
      end
    end
  end

  context "creation" do
    context "when official_proposals setting is enabled" do
      before do
        current_feature.update_attributes(settings: { official_proposals_enabled: true } )
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
            participatory_process.update_attributes(scope_ids: [])
          end

          it "can be related to a scope" do
            find(".actions .new").click

            within "form" do
              expect(page).to have_content(/Scope/i)
            end
          end
        end

        context "when process is related to a scope" do
          before do
            participatory_process.update_attributes(scope_ids: [scope.id])
          end

          it "cannot be related to a scope" do
            find(".actions .new").click

            within "form" do
              expect(page).not_to have_content(/Scope/i)
            end
          end
        end

        it "creates a new proposal" do
          find(".actions .new").click

          within ".new_proposal" do
            fill_in :proposal_title, with: "Make decidim great again"
            fill_in :proposal_body, with: "Decidim is great but it can be better"
            select category.name["en"], from: :proposal_category_id
            select scope.name, from: :proposal_scope_id

            find("*[type=submit]").click
          end

          within ".flash" do
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

    context "when official_proposals setting is disabled" do
      before do
        current_feature.update_attributes(settings: { official_proposals_enabled: false } )
      end

      it "cannot create a new proposal" do
        visit_feature
        expect(page).not_to have_selector(".actions .new")
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
          click_link "Answer"
        end

        within ".edit_proposal_answer" do
          fill_in_i18n(
            :proposal_answer_answer,
            "#answer-tabs",
            en: "The proposal doesn't make any sense",
            es: "La propuesta no tiene sentido",
            ca: "La proposta no te sentit"
          )
          choose "Rejected"
          click_button "Answer proposal"
        end

        within ".flash" do
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
          click_link "Answer"
        end

        within ".edit_proposal_answer" do
          choose "Accepted"
          click_button "Answer proposal"
        end

        within ".flash" do
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

  context "listing reported proposals" do
    let!(:reported_proposals) { create_list(:proposal, 3, :reported, feature: current_feature) }

    it "user can review them" do
      visit current_path

      click_link "Reported proposals"

      reported_proposals.each do |proposal|
        expect(page).to have_selector("tr", text: proposal.title)
        expect(page).to have_selector("tr", text: proposal.reports.first.reason)
      end
    end

    it "user can un-report a proposal" do
      visit current_path

      click_link "Reported proposals"

      within find("tr", text: reported_proposals.first.title) do
        click_link "Unreport"
      end

      within ".flash" do
        expect(page).to have_content("Proposal successfully unreported")
      end
    end

    it "user can hide a proposal" do
      visit current_path

      click_link "Reported proposals"

      within find("tr", text: reported_proposals.first.title) do
        click_link "Hide"
      end

      within ".flash" do
        expect(page).to have_content("Proposal successfully hidden")
      end

      expect(page).to have_no_content(reported_proposals.first.title)
    end
  end

  context "listing hidden proposals" do
    let!(:hidden_proposals) { create_list(:proposal, 3, :hidden, feature: current_feature) }

    it "user can review them" do
      visit current_path

      click_link "Hidden proposals"

      hidden_proposals.each do |proposal|
        expect(page).to have_selector("tr", text: proposal.title)
      end
    end
  end
end
