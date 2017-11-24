# frozen_string_literal: true

shared_examples "manage proposals" do
  let(:address) { "Carrer Pare Llaurador 113, baixos, 08224 Terrassa" }
  let(:latitude) { 40.1234 }
  let(:longitude) { 2.1234 }

  before do
    Geocoder::Lookup::Test.add_stub(
      address,
      [{ "latitude" => latitude, "longitude" => longitude }]
    )
  end

  context "when previewing proposals" do
    it "allows the user to preview the proposal" do
      within find("tr", text: proposal.title) do
        klass = "action-icon--preview"
        href = resource_locator(proposal).path
        target = "blank"

        expect(page).to have_selector(
          :xpath,
          "//a[contains(@class,'#{klass}')][@href='#{href}'][@target='#{target}']"
        )
      end
    end
  end

  describe "creation" do
    context "when official_proposals setting is enabled" do
      before do
        current_feature.update_attributes!(settings: { official_proposals_enabled: true })
      end

      context "when creation is enabled" do
        before do
          current_feature.update_attributes!(
            step_settings: {
              current_feature.participatory_space.active_step.id => {
                creation_enabled: true
              }
            }
          )

          visit_feature_admin
        end

        context "when process is not related to any scope" do
          before do
            participatory_process.update_attributes!(scope: nil)

            click_link "New"
          end

          it "can be related to a scope" do
            within "form" do
              expect(page).to have_content(/Scope/i)
            end
          end

          it "creates a new proposal" do
            within ".new_proposal" do
              fill_in :proposal_title, with: "Make decidim great again"
              fill_in :proposal_body, with: "Decidim is great but it can be better"
              select translated(category.name), from: :proposal_category_id
              select2 translated(scope.name), from: :proposal_scope_id

              find("*[type=submit]").click
            end

            expect(page).to have_admin_callout("successfully")

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
            participatory_process.update_attributes!(scope: scope)
          end

          it "cannot be related to a scope" do
            click_link "New"

            within "form" do
              expect(page).to have_no_content(/Scope/i)
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

            expect(page).to have_admin_callout("successfully")

            within "table" do
              proposal = Decidim::Proposals::Proposal.last

              expect(page).to have_content("Make decidim great again")
              expect(proposal.body).to eq("Decidim is great but it can be better")
              expect(proposal.category).to eq(category)
              expect(proposal.scope).to eq(scope)
            end
          end

          context "when geocoding is enabled" do
            before do
              current_feature.update_attributes!(settings: { geocoding_enabled: true })
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

              expect(page).to have_admin_callout("successfully")

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

        context "when attachments are allowed", processing_uploads_for: Decidim::AttachmentUploader do
          before do
            current_feature.update_attributes!(settings: { attachments_allowed: true })
          end

          it "creates a new proposal with attachments" do
            click_link "New"

            within ".new_proposal" do
              fill_in :proposal_title, with: "Proposal with attachments"
              fill_in :proposal_body, with: "This is my proposal and I want to upload attachments."
              fill_in :proposal_attachment_title, with: "My attachment"
              attach_file :proposal_attachment_file, Decidim::Dev.asset("city.jpeg")
              find("*[type=submit]").click
            end

            expect(page).to have_admin_callout("successfully")

            visit resource_locator(Decidim::Proposals::Proposal.last).path
            expect(page).to have_selector("img[src*=\"city.jpeg\"]", count: 1)
          end
        end
      end

      context "when creation is not enabled" do
        before do
          current_feature.update_attributes!(
            step_settings: {
              current_feature.participatory_space.active_step.id => {
                creation_enabled: false
              }
            }
          )
        end

        it "cannot create a new proposal from the main site" do
          visit_feature
          expect(page).to have_no_button("New Proposal")
        end

        it "cannot create a new proposal from the admin site" do
          visit_feature_admin
          expect(page).to have_no_link(/New/)
        end
      end
    end

    context "when official_proposals setting is disabled" do
      before do
        current_feature.update_attributes!(settings: { official_proposals_enabled: false })
      end

      it "cannot create a new proposal from the main site" do
        visit_feature
        expect(page).to have_no_button("New Proposal")
      end

      it "cannot create a new proposal from the admin site" do
        visit_feature_admin
        expect(page).to have_no_link(/New/)
      end
    end
  end

  context "when the proposal_answering feature setting is enabled" do
    before do
      current_feature.update_attributes!(settings: { proposal_answering_enabled: true })
    end

    context "when the proposal_answering step setting is enabled" do
      before do
        current_feature.update_attributes!(
          step_settings: {
            current_feature.participatory_space.active_step.id => {
              proposal_answering_enabled: true
            }
          }
        )
      end

      it "can reject a proposal" do
        go_to_edit_answer(proposal)

        within ".edit_proposal_answer" do
          fill_in_i18n_editor(
            :proposal_answer_answer,
            "#proposal_answer-answer-tabs",
            en: "The proposal doesn't make any sense",
            es: "La propuesta no tiene sentido",
            ca: "La proposta no te sentit"
          )
          choose "Rejected"
          click_button "Answer"
        end

        expect(page).to have_admin_callout("Proposal successfully answered")

        within find("tr", text: proposal.title) do
          expect(page).to have_content("Rejected")
        end
      end

      it "can accept a proposal" do
        go_to_edit_answer(proposal)

        within ".edit_proposal_answer" do
          choose "Accepted"
          click_button "Answer"
        end

        expect(page).to have_admin_callout("Proposal successfully answered")

        within find("tr", text: proposal.title) do
          expect(page).to have_content("Accepted")
        end
      end

      it "can mark a proposal as evaluating" do
        go_to_edit_answer(proposal)

        within ".edit_proposal_answer" do
          choose "Evaluating"
          click_button "Answer"
        end

        expect(page).to have_admin_callout("Proposal successfully answered")

        within find("tr", text: proposal.title) do
          expect(page).to have_content("Evaluating")
        end
      end

      it "can edit a proposal answer" do
        proposal.update_attributes!(
          state: "rejected",
          answer: {
            "en" => "I don't like it"
          },
          answered_at: Time.current
        )

        visit_feature_admin

        within find("tr", text: proposal.title) do
          expect(page).to have_content("Rejected")
        end

        go_to_edit_answer(proposal)

        within ".edit_proposal_answer" do
          choose "Accepted"
          click_button "Answer"
        end

        expect(page).to have_admin_callout("Proposal successfully answered")

        within find("tr", text: proposal.title) do
          expect(page).to have_content("Accepted")
        end
      end
    end

    context "when the proposal_answering step setting is disabled" do
      before do
        current_feature.update_attributes!(
          step_settings: {
            current_feature.participatory_space.active_step.id => {
              proposal_answering_enabled: false
            }
          }
        )
      end

      it "cannot answer a proposal" do
        visit current_path

        within find("tr", text: proposal.title) do
          expect(page).to have_no_link("Answer")
        end
      end
    end
  end

  context "when the proposal_answering feature setting is disabled" do
    before do
      current_feature.update_attributes!(settings: { proposal_answering_enabled: false })
    end

    it "cannot answer a proposal" do
      visit current_path

      within find("tr", text: proposal.title) do
        expect(page).to have_no_link("Answer")
      end
    end
  end

  context "when the votes_enabled feature setting is disabled" do
    before do
      current_feature.update_attributes!(
        step_settings: {
          feature.participatory_space.active_step.id => {
            votes_enabled: false
          }
        }
      )
    end

    it "doesn't show the votes column" do
      visit current_path

      within "thead" do
        expect(page).not_to have_content("VOTES")
      end
    end
  end

  context "when the votes_enabled feature setting is enabled" do
    before do
      current_feature.update_attributes!(
        step_settings: {
          feature.participatory_space.active_step.id => {
            votes_enabled: true
          }
        }
      )
    end

    it "shows the votes column" do
      visit current_path

      within "thead" do
        expect(page).to have_content("VOTES")
      end
    end
  end

  def go_to_edit_answer(proposal)
    within find("tr", text: proposal.title) do
      click_link "Answer"
    end

    expect(page).to have_selector(".edit_proposal_answer")
  end
end
