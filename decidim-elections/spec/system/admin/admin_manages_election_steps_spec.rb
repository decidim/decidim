# frozen_string_literal: true

require "spec_helper"

describe "Admin manages election steps", :slow do
  include Decidim::Elections::FullElectionHelpers
  include_context "with test bulletin board"
  include_context "when admin manages elections"

  describe "setup an election" do
    let(:election) { create(:election, :ready_for_setup, component: current_component, title: { en: "English title", es: "" }) }
    let(:bulletin_board_server) { Decidim::BulletinBoard.config[:bulletin_board_server] }
    let(:authority_name) { Decidim::BulletinBoard.config[:authority_name] }
    let(:scheme_name) { Decidim::BulletinBoard.config[:scheme_name] }

    it "shows the election technical information" do
      visit_steps_page
      click_link "View technical information"

      within ".form.step.create_election" do
        expect(page).to have_content("Bulletin Board server")
        expect(page).to have_content(bulletin_board_server)
        expect(page).to have_content("Authority name")
        expect(page).to have_content(authority_name)
        expect(page).to have_content("Scheme name")
        expect(page).to have_content(scheme_name)
      end
    end

    it "performs the action successfully" do
      visit_steps_page

      within "form.create_election" do
        expect(page).to have_content("The election has at least 1 question.")
        expect(page).to have_content("Each question has at least 2 answers.")
        expect(page).to have_content("All the questions have a correct value for maximum of answers.")
        expect(page).to have_content("The election is published.")
        expect(page).to have_content("The election component is published.")
        expect(page).to have_content("The setup is being done at least 1 hour before the election starts.")
        expect(page).to have_content("The participatory space has at least 3 trustees with public key.")
        expect(page).to have_content("has a public key", minimum: 2)
        expect(page).not_to have_content("Census is uploaded.")
        expect(page).not_to have_content("Census codes are generated.")
        expect(page).not_to have_content("Codes are exported and census is frozen.")

        click_button "Setup election"
      end

      expect(page).to have_admin_callout("successfully")

      within ".form.created" do
        expect(page).to have_content("Election created")
        expect(page).to have_content("Start the key ceremony")
      end
    end

    context "when election is not ready for setup" do
      let(:election) { create(:election, component: current_component, start_time: 5.minutes.ago) }
      let(:router) { Decidim::EngineRouter.admin_proxy(component) }
      let(:errors_and_links) do
        {
          "The election must have at least one question.": router.election_questions_path(election),
          "Questions must have at least two answers.": router.election_questions_path(election),
          "The questions do not have a correct value for amount of answers": router.election_questions_path(election),
          "The election is not published.": router.publish_election_path(election),
          "The start time is in less than 1 hour before the election starts.": router.edit_election_path(election),
          "The participatory space must have at least 3 trustees with public key.": router.trustees_path
        }
      end

      before do
        visit_steps_page
      end

      it "shows all the error texts and links to fix them" do
        within("form.create_election") do
          errors_and_links.each do |error_text, link|
            expect(page).to have_content(error_text)
            li = find("li", text: error_text)
            expect(li).to have_link("Fix it", href: link)
          end
        end
      end
    end

    context "when census is required" do
      let!(:voting) { create(:voting, organization:) }
      let(:participatory_space) { voting }

      it "shows invalid census messages" do
        visit_steps_page

        within "form.create_election" do
          expect(page).to have_content("The election has at least 1 question.")
          expect(page).to have_content("Each question has at least 2 answers.")
          expect(page).to have_content("All the questions have a correct value for maximum of answers.")
          expect(page).to have_content("The election is published.")
          expect(page).to have_content("The election component is published.")
          expect(page).to have_content("The setup is being done at least 1 hour before the election starts.")
          expect(page).to have_content("The participatory space has at least 3 trustees with public key.")
          expect(page).to have_content("has a public key", minimum: 2)
          expect(page).to have_content("There is no census uploaded for this election.")
          expect(page).to have_content("Access codes for the census are not generated.")
          expect(page).to have_content("Access codes for the census are not exported.")
          expect(page).not_to have_content("Fix it")
        end
      end

      context "with valid census" do
        let!(:dataset) { create(:dataset, :codes_generated, :frozen, voting:) }

        it "shows valid census messages" do
          visit_steps_page

          within "form.create_election" do
            expect(page).to have_content("Census is uploaded.")
            expect(page).to have_content("Access codes for the census are generated.")
            expect(page).to have_content("Access codes for the census are exported and census is frozen.")
          end
        end
      end
    end
  end

  describe "start the key ceremony" do
    let(:election) { create(:election, :bb_test, :created, component: current_component) }

    it "performs the action successfully" do
      visit_steps_page

      within ".form.created" do
        expect(page).to have_content("Trustees")

        click_button "Start the key ceremony"
      end

      expect(page).to have_admin_callout("successfully")

      within ".form.created" do
        expect(page).to have_content("Processing...")
      end

      within ".content.key_ceremony" do
        expect(page).to have_content("Key ceremony")
      end
    end
  end

  describe "view key ceremony step", :slow, download: true do
    include_context "when performing the whole process"

    it "shows the step information" do
      setup_election

      visit_steps_page
      expect(page).to have_content("Key ceremony")
      expect(page).to have_css(".loading") # It shows the loading icon
      expect(page).not_to have_css(".active") # The trustees did not participate yet
      expect(page).to have_link("Continue", class: "disabled")

      download_election_keys(0)
      download_election_keys(1)
      download_election_keys(2)

      visit_steps_page
      expect(page).to have_content("Key ceremony")
      expect(page).not_to have_css(".loading") # It is not waiting for any trustee
      expect(page).to have_css(".active") # All the trustees are active
      expect(page).not_to have_link("Continue", class: "disabled")
      expect(page).to have_link("Continue")
    end
  end

  describe "start the voting period" do
    let(:election) { create(:election, :bb_test, :key_ceremony_ended, component: current_component) }

    it "performs the action successfully" do
      visit_steps_page

      within ".form.key_ceremony_ended" do
        expect(page).to have_content("The election will start soon.")

        click_button "Start voting period"
      end

      expect(page).to have_admin_callout("successfully")

      within ".form.key_ceremony_ended" do
        expect(page).to have_content("Processing...")
      end

      within ".form.vote" do
        expect(page).to have_content("Vote period")
      end
    end
  end

  describe "voting period" do
    let(:election) { create(:election, :bb_test, :vote, component: current_component) }

    context "with no vote statistics" do
      it "shows text about vote statistics" do
        visit_steps_page

        within "#vote-stats" do
          expect(page).to have_content("Vote Statistics")
          expect(page).to have_content("No vote statistics yet")
        end
      end
    end

    context "with vote statistics" do
      let!(:user1) { create(:user, :confirmed) }
      let!(:user2) { create(:user, :confirmed) }
      let!(:user1_votes) { create_list(:vote, 3, election:, status: "accepted", voter_id: "voter_#{user1.id}") }
      let!(:user2_votes) { create(:vote, election:, status: "accepted", voter_id: "voter_#{user2.id}") }

      it "shows votes and unique voters" do
        visit_steps_page

        within "#vote-stats" do
          expect(page).to have_content("Votes")
          expect(page).to have_content("Voters")

          votes = find(:xpath, '//*[@id="vote-stats"]/div/div[2]/table/tbody/tr/td[2]')
          expect(votes).to have_content("4")

          voters = find(:xpath, '//*[@id="vote-stats"]/div/div[2]/table/tbody/tr/td[3]')
          expect(voters).to have_content("2")
        end
      end
    end
  end

  describe "end the voting period" do
    let(:election) { create(:election, :bb_test, :vote, :finished, component: current_component) }

    it "performs the action successfully" do
      visit_steps_page

      within ".form.vote" do
        expect(page).to have_content("The election has ended.")

        click_button "End voting period"
      end

      expect(page).to have_admin_callout("successfully")

      within ".form.vote" do
        expect(page).to have_content("Processing...")
      end

      within ".form.vote_ended" do
        expect(page).to have_content("Start tally")
      end
    end
  end

  describe "start the tally" do
    let(:election) { create(:election, :bb_test, :vote_ended, component: current_component) }

    it "performs the action successfully" do
      visit_steps_page

      within ".form.vote_ended" do
        expect(page).to have_content("Vote period ended")

        click_button "Start tally"
      end

      expect(page).to have_admin_callout("successfully")

      within ".form.vote_ended" do
        expect(page).to have_content("Processing...")
      end

      within ".form.tally_started" do
        expect(page).to have_content("Tally process")
      end
    end
  end

  describe "report missing trustee" do
    let(:election) { create(:election, :bb_test, :tally_started, component: current_component) }
    let(:trustee) { election.trustees.first }

    it "marks the trustee as missing" do
      visit_steps_page

      # allows admin to mark trustees as missing
      expect(page).to have_button(text: "Mark as missing")

      within find("tr", text: trustee.name) do
        click_button "Mark as missing"
      end

      expect(page).to have_admin_callout("successfully")

      # shows the trustee as missing
      within find("tr", text: trustee.name) do
        expect(page).to have_css(".missing")
      end

      # do not allow to mark more trustees as missing
      expect(page).not_to have_button(text: "Mark as missing")
    end
  end

  describe "tally ended" do
    let(:election) { create(:election, :tally_ended, component: current_component) }
    let(:question) { election.questions.first }
    let(:answer) { question.answers.first }

    it "shows the calculated results" do
      visit_steps_page

      within ".form.tally_ended" do
        expect(page).to have_content("Calculated results")
        expect(page).to have_content(translated(question.title))
        expect(page).to have_content(translated(answer.title))
        expect(page).to have_content(answer.results_total)
      end
    end
  end

  describe "publishing results" do
    let(:election) { create(:election, :bb_test, :tally_ended, component: current_component) }
    let(:question) { election.questions.first }
    let(:answer) { question.answers.first }

    it "performs the action successfully" do
      visit_steps_page

      within ".form.tally_ended" do
        expect(page).to have_content("Calculated results")

        click_button "Publish results"
      end

      expect(page).to have_admin_callout("successfully")

      within ".form.tally_ended" do
        expect(page).to have_content("Processing...")
      end

      within ".content.results_published" do
        expect(page).to have_content("Results published")
      end
    end
  end

  def visit_steps_page
    election

    relogin_as user, scope: :user
    visit_component_admin

    within find("tr", text: translated(election.title)) do
      page.find(".action-icon--manage-steps").click
    end

    # Ensure the correct page is loaded before proceeding further
    if election.bb_status.nil?
      within ".form.step.create_election .card .card-divider", match: :first do
        expect(page).to have_css(".card-title", text: "Setup election")
      end
    else
      expect(page).to have_css(".item_show__header .item_show__header-title", text: translated(election.title))
    end
  end
end
