# frozen_string_literal: true

shared_examples "manage proposals" do
  let(:address) { "Carrer Pare Llaurador 113, baixos, 08224 Terrassa" }
  let(:latitude) { 40.1234 }
  let(:longitude) { 2.1234 }
  let(:participatory_process) { create(:participatory_process, :with_steps, organization: organization, scope: participatory_process_scope) }
  let(:participatory_process_scope) { nil }
  let(:proposal_title) { translated(proposal.title) }

  before do
    stub_geocoding(address, [latitude, longitude])
  end

  context "when previewing proposals" do
    it "allows the user to preview the proposal" do
      within find("tr", text: proposal_title) do
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
        current_component.update!(settings: { official_proposals_enabled: true })
      end

      context "when creation is enabled" do
        before do
          current_component.update!(
            step_settings: {
              current_component.participatory_space.active_step.id => {
                creation_enabled: true
              }
            }
          )

          visit_component_admin
        end

        describe "admin form" do
          before { click_on "New proposal" }

          it_behaves_like "having a rich text editor", "new_proposal", "full"
        end

        context "when process is not related to any scope" do
          it "can be related to a scope" do
            click_link "New proposal"

            within "form" do
              expect(page).to have_content(/Scope/i)
            end
          end

          it "creates a new proposal", :slow do
            click_link "New proposal"

            within ".new_proposal" do
              fill_in :proposal_title, with: "Make decidim great again"
              fill_in_editor :proposal_body, with: "Decidim is great but it can be better"
              select translated(category.name), from: :proposal_category_id
              scope_pick select_data_picker(:proposal_scope_id), scope
              find("*[type=submit]").click
            end

            expect(page).to have_admin_callout("successfully")

            within "table" do
              proposal = Decidim::Proposals::Proposal.last

              expect(page).to have_content("Make decidim great again")
              expect(proposal.body).to eq("<p>Decidim is great but it can be better</p>")
              expect(proposal.category).to eq(category)
              expect(proposal.scope).to eq(scope)
            end
          end
        end

        context "when process is related to a scope" do
          before do
            component.update!(settings: { scopes_enabled: false })
          end

          let(:participatory_process_scope) { scope }

          it "cannot be related to a scope, because it has no children" do
            click_link "New proposal"

            within "form" do
              expect(page).to have_no_content(/Scope/i)
            end
          end

          it "creates a new proposal related to the process scope" do
            click_link "New proposal"

            within ".new_proposal" do
              fill_in :proposal_title, with: "Make decidim great again"
              fill_in_editor :proposal_body, with: "Decidim is great but it can be better"
              select category.name["en"], from: :proposal_category_id
              find("*[type=submit]").click
            end

            expect(page).to have_admin_callout("successfully")

            within "table" do
              proposal = Decidim::Proposals::Proposal.last

              expect(page).to have_content("Make decidim great again")
              expect(proposal.body).to eq("<p>Decidim is great but it can be better</p>")
              expect(proposal.category).to eq(category)
              expect(proposal.scope).to eq(scope)
            end
          end

          context "when the process scope has a child scope" do
            let!(:child_scope) { create :scope, parent: scope }

            it "can be related to a scope" do
              click_link "New proposal"

              within "form" do
                expect(page).to have_content(/Scope/i)
              end
            end

            it "creates a new proposal related to a process scope child" do
              click_link "New proposal"

              within ".new_proposal" do
                fill_in :proposal_title, with: "Make decidim great again"
                fill_in_editor :proposal_body, with: "Decidim is great but it can be better"
                select category.name["en"], from: :proposal_category_id
                scope_repick select_data_picker(:proposal_scope_id), scope, child_scope
                find("*[type=submit]").click
              end

              expect(page).to have_admin_callout("successfully")

              within "table" do
                proposal = Decidim::Proposals::Proposal.last

                expect(page).to have_content("Make decidim great again")
                expect(proposal.body).to eq("<p>Decidim is great but it can be better</p>")
                expect(proposal.category).to eq(category)
                expect(proposal.scope).to eq(child_scope)
              end
            end
          end

          context "when geocoding is enabled" do
            before do
              current_component.update!(settings: { geocoding_enabled: true })
            end

            it "creates a new proposal related to the process scope" do
              click_link "New proposal"

              within ".new_proposal" do
                fill_in :proposal_title, with: "Make decidim great again"
                fill_in_editor :proposal_body, with: "Decidim is great but it can be better"
                fill_in :proposal_address, with: address
                select category.name["en"], from: :proposal_category_id
                find("*[type=submit]").click
              end

              expect(page).to have_admin_callout("successfully")

              within "table" do
                proposal = Decidim::Proposals::Proposal.last

                expect(page).to have_content("Make decidim great again")
                expect(proposal.body).to eq("<p>Decidim is great but it can be better</p>")
                expect(proposal.category).to eq(category)
                expect(proposal.scope).to eq(scope)
              end
            end
          end
        end

        context "when attachments are allowed", processing_uploads_for: Decidim::AttachmentUploader do
          before do
            current_component.update!(settings: { attachments_allowed: true })
          end

          it "creates a new proposal with attachments" do
            click_link "New proposal"

            within ".new_proposal" do
              fill_in :proposal_title, with: "Proposal with attachments"
              fill_in_editor :proposal_body, with: "This is my proposal and I want to upload attachments."
              fill_in :proposal_attachment_title, with: "My attachment"
              attach_file :proposal_attachment_file, Decidim::Dev.asset("city.jpeg")
              find("*[type=submit]").click
            end

            expect(page).to have_admin_callout("successfully")

            visit resource_locator(Decidim::Proposals::Proposal.last).path
            expect(page).to have_selector("img[src*=\"city.jpeg\"]", count: 1)
          end
        end

        context "when proposals comes from a meeting" do
          let!(:meeting_component) { create(:meeting_component, participatory_space: participatory_process) }
          let!(:meetings) { create_list(:meeting, 3, component: meeting_component) }

          it "creates a new proposal with meeting as author" do
            click_link "New proposal"

            within ".new_proposal" do
              fill_in :proposal_title, with: "Proposal with meeting as author"
              fill_in_editor :proposal_body, with: "Proposal body of meeting as author"
              execute_script("$('#proposal_created_in_meeting').change()")
              find(:css, "#proposal_created_in_meeting").set(true)
              select translated(meetings.first.title), from: :proposal_meeting_id
              select category.name["en"], from: :proposal_category_id
              find("*[type=submit]").click
            end

            expect(page).to have_admin_callout("successfully")

            within "table" do
              proposal = Decidim::Proposals::Proposal.last

              expect(page).to have_content("Proposal with meeting as author")
              expect(proposal.body).to eq("<p>Proposal body of meeting as author</p>")
              expect(proposal.category).to eq(category)
            end
          end
        end
      end

      context "when creation is not enabled" do
        before do
          current_component.update!(
            step_settings: {
              current_component.participatory_space.active_step.id => {
                creation_enabled: false
              }
            }
          )
        end

        it "cannot create a new proposal from the main site" do
          visit_component
          expect(page).to have_no_button("New Proposal")
        end

        it "cannot create a new proposal from the admin site" do
          visit_component_admin
          expect(page).to have_no_link(/New/)
        end
      end
    end

    context "when official_proposals setting is disabled" do
      before do
        current_component.update!(settings: { official_proposals_enabled: false })
      end

      it "cannot create a new proposal from the main site" do
        visit_component
        expect(page).to have_no_button("New Proposal")
      end

      it "cannot create a new proposal from the admin site" do
        visit_component_admin
        expect(page).to have_no_link(/New/)
      end
    end
  end

  context "when the proposal_answering component setting is enabled" do
    before do
      current_component.update!(settings: { proposal_answering_enabled: true })
    end

    context "when the proposal_answering step setting is enabled" do
      before do
        current_component.update!(
          step_settings: {
            current_component.participatory_space.active_step.id => {
              proposal_answering_enabled: true
            }
          }
        )
      end

      it "can reject a proposal" do
        go_to_admin_proposal_page_answer_section(proposal)

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

        within find("tr", text: proposal_title) do
          expect(page).to have_content("Rejected")
        end
      end

      it "can accept a proposal" do
        go_to_admin_proposal_page_answer_section(proposal)

        within ".edit_proposal_answer" do
          choose "Accepted"
          click_button "Answer"
        end

        expect(page).to have_admin_callout("Proposal successfully answered")

        within find("tr", text: proposal_title) do
          expect(page).to have_content("Accepted")
        end
      end

      it "can mark a proposal as evaluating" do
        go_to_admin_proposal_page_answer_section(proposal)

        within ".edit_proposal_answer" do
          choose "Evaluating"
          click_button "Answer"
        end

        expect(page).to have_admin_callout("Proposal successfully answered")

        within find("tr", text: proposal_title) do
          expect(page).to have_content("Evaluating")
        end
      end

      it "can edit a proposal answer" do
        proposal.update!(
          state: "rejected",
          answer: {
            "en" => "I don't like it"
          },
          answered_at: Time.current
        )

        visit_component_admin

        within find("tr", text: proposal_title) do
          expect(page).to have_content("Rejected")
        end

        go_to_admin_proposal_page_answer_section(proposal)

        within ".edit_proposal_answer" do
          choose "Accepted"
          click_button "Answer"
        end

        expect(page).to have_admin_callout("Proposal successfully answered")

        within find("tr", text: proposal_title) do
          expect(page).to have_content("Accepted")
        end
      end
    end

    context "when the proposal_answering step setting is disabled" do
      before do
        current_component.update!(
          step_settings: {
            current_component.participatory_space.active_step.id => {
              proposal_answering_enabled: false
            }
          }
        )
      end

      it "cannot answer a proposal" do
        visit current_path

        within find("tr", text: proposal_title) do
          expect(page).to have_no_link("Answer")
        end
      end
    end

    context "when the proposal is an emendation" do
      let!(:amendable) { create(:proposal, component: current_component) }
      let!(:emendation) { create(:proposal, component: current_component) }
      let!(:amendment) { create :amendment, amendable: amendable, emendation: emendation, state: "evaluating" }

      it "cannot answer a proposal" do
        visit_component_admin
        within find("tr", text: I18n.t("decidim/amendment", scope: "activerecord.models", count: 1)) do
          expect(page).to have_no_link("Answer")
        end
      end
    end
  end

  context "when the proposal_answering component setting is disabled" do
    before do
      current_component.update!(settings: { proposal_answering_enabled: false })
    end

    it "cannot answer a proposal" do
      go_to_admin_proposal_page(proposal)

      expect(page).to have_no_selector(".edit_proposal_answer")
    end
  end

  context "when the votes_enabled component setting is disabled" do
    before do
      current_component.update!(
        step_settings: {
          component.participatory_space.active_step.id => {
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

  context "when the votes_enabled component setting is enabled" do
    before do
      current_component.update!(
        step_settings: {
          component.participatory_space.active_step.id => {
            votes_enabled: true
          }
        }
      )
    end

    it "shows the votes column" do
      visit current_path

      within "thead" do
        expect(page).to have_content("Votes")
      end
    end
  end

  def go_to_admin_proposal_page(proposal)
    proposal_title = translated(proposal.title)
    within find("tr", text: proposal_title) do
      find("a", class: "action-icon--show-proposal").click
    end
  end

  def go_to_admin_proposal_page_answer_section(proposal)
    go_to_admin_proposal_page(proposal)

    expect(page).to have_selector(".edit_proposal_answer")
  end
end
