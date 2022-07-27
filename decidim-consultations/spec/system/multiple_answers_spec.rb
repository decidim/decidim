# frozen_string_literal: true

require "spec_helper"

describe "Multiple Answers Question", type: :system do
  let(:organization) { create(:organization) }
  let(:consultation) { create(:consultation, :active, organization:) }
  let(:question) { create :question, :multiple, :published, consultation: }
  let(:user) { create :user, :confirmed, organization: }

  context "and guest user" do
    before do
      switch_to_host(organization.host)
      visit decidim_consultations.question_path(question)
    end

    it "Shows the basic question data" do
      expect(page).to have_i18n_content(question.promoter_group)
      expect(page).to have_i18n_content(question.scope.name)
      expect(page).to have_i18n_content(question.participatory_scope)
      expect(page).to have_i18n_content(question.question_context)

      expect(page).not_to have_i18n_content(question.what_is_decided)
    end

    it "Page contains a vote button" do
      expect(page).to have_button(id: "vote_button")
      expect(page).not_to have_link(id: "multivote_button")
    end

    it "Page do not contains an unvote button" do
      expect(page).not_to have_button(id: "unvote_button")
    end
  end

  context "and authenticated user" do
    context "and never voted before" do
      before do
        switch_to_host(organization.host)
        login_as user, scope: :user
        visit decidim_consultations.question_path(question)
      end

      it "Page contains a vote button" do
        expect(page).to have_link(id: "multivote_button")
      end

      it "voting leads to a new page" do
        click_link(id: "multivote_button")
        expect(page).to have_current_path decidim_consultations.question_question_multiple_votes_path(question)
      end
    end

    context "when voting" do
      let!(:response1) { create :response, question: }
      let!(:response2) { create :response, question: }
      let!(:response3) { create :response, question: }
      let!(:response4) { create :response, question: }

      before do
        switch_to_host(organization.host)
        login_as user, scope: :user
        visit decidim_consultations.question_question_multiple_votes_path(question)
      end

      it "Page contains vote button" do
        expect(page).to have_button(id: "vote_button")
      end

      it "Page contains number of votes available" do
        within "#remaining-votes-count" do
          expect(page).to have_content("3")
        end
      end

      it "Page decreases number of votes on voting" do
        check("vote_id_#{response1.id}")

        within "#remaining-votes-count" do
          expect(page).to have_content("2")
        end
      end

      it "Page do not allow to vote over maximum" do
        check("vote_id_#{response1.id}")
        check("vote_id_#{response2.id}")
        check("vote_id_#{response3.id}")
        check("vote_id_#{response4.id}")

        within "#remaining-votes-count" do
          expect(page).to have_content("0")
        end

        expect(page).to have_checked_field("vote_id_#{response1.id}")
        expect(page).to have_checked_field("vote_id_#{response2.id}")
        expect(page).to have_checked_field("vote_id_#{response3.id}")
        expect(page).not_to have_checked_field("vote_id_#{response4.id}")
      end

      it "unvote button appears after voting" do
        check("vote_id_#{response1.id}")
        check("vote_id_#{response2.id}")
        click_button("vote_button")

        expect(page).to have_current_path decidim_consultations.question_path(question)
        expect(page).to have_button(id: "unvote_button")
      end
    end

    context "and voted before" do
      let!(:response1) { create :response, question: }
      let!(:response2) { create :response, question: }
      let!(:vote1) do
        create :vote, author: user, question:, response: response1
      end
      let!(:vote2) do
        create :vote, author: user, question:, response: response2
      end

      before do
        switch_to_host(organization.host)
        login_as user, scope: :user
        visit decidim_consultations.question_path(question)
      end

      it "contains an unvote button" do
        expect(page).to have_button(id: "unvote_button")
      end

      it "vote button appears after unvoting" do
        click_button(id: "unvote_button")
        expect(page).to have_link(id: "multivote_button")
      end
    end
  end
end
