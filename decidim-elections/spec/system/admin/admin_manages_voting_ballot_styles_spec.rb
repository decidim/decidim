# frozen_string_literal: true

require "spec_helper"

describe "Admin manages ballot styles", type: :system do
  let(:address) { "Somewhere over the rainbow" }
  let(:latitude) { 42.123 }
  let(:longitude) { 2.123 }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_votings.edit_voting_path(voting)
    click_link "Ballot Styles"
  end

  include_context "when admin managing a voting"

  context "when processing the ballot styles" do
    let!(:ballot_style) { create(:ballot_style, :with_ballot_style_questions, voting: voting) }

    before do
      visit current_path
    end

    context "when listing the ballot styles" do
      it "lists all the ballot styles for the voting" do
        within "#ballot_styles table" do
          expect(page).to have_content(ballot_style.code)
          each_question do |question|
            expect(page).to have_content(translated(question.title).slice(0, 2))
            expect(page).to have_content(translated(question.election.title))
          end
        end
      end
    end

    it "can add a ballot style" do
      click_link("New")

      within ".new_ballot_style" do
        fill_in :ballot_style_code, with: "new code"

        check translated(ballot_style.questions.sample.title)

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "#ballot_styles table" do
        expect(page).to have_text("NEW CODE")
        expect(page).to have_selector(".icon--check", count: ballot_style.questions.count + 1)
      end
    end

    it "can delete a ballot style" do
      within find("tr", text: ballot_style.code) do
        accept_confirm { click_link "Delete" }
      end

      expect(page).to have_admin_callout("successfully")

      expect(page).to have_no_content(ballot_style.code)
    end

    it "can update a ballot style" do
      within "#ballot_styles" do
        within find("tr", text: ballot_style.code) do
          click_link "Edit"
        end
      end

      within ".edit_ballot_style" do
        fill_in :ballot_style_code, with: "updated code"

        each_question do |question|
          uncheck translated(question.title)
        end

        check translated(ballot_style.questions.sample.title)

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "#ballot_styles table" do
        expect(page).to have_text("UPDATED CODE")
        expect(page).to have_selector(".icon--check", count: 1)
      end
    end
  end

  def each_question
    ballot_style.questions.each do |question|
      yield question
    end
  end
end
