# frozen_string_literal: true

require "spec_helper"

describe "Question vote", type: :system do
  let(:organization) { create(:organization) }
  let(:question) { create :question, :published, consultation: }

  context "when upcoming consultation" do
    let(:consultation) { create(:consultation, :published, :upcoming, organization:) }

    before do
      switch_to_host(organization.host)
      visit decidim_consultations.question_path(question)
    end

    it "contains a disabled vote button" do
      expect(page).to have_css(".question-vote-cabin .card__button.disabled")
    end

    it "shows when the voting period starts" do
      expect(page).to have_content("Starting from #{I18n.l(question.start_voting_date)}")
    end
  end

  context "when finished consultation" do
    let(:consultation) { create(:consultation, :finished, organization:) }
    let(:user) { create :user, :confirmed, organization: }

    context "and guest user" do
      before do
        switch_to_host(organization.host)
        visit decidim_consultations.question_path(question)
      end

      it "Page do not contains an vote button" do
        expect(page).not_to have_button(id: "vote_button")
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

        it "Page do not contains an vote button" do
          expect(page).not_to have_button(id: "vote_button")
        end

        it "Page do not contains an unvote button" do
          expect(page).not_to have_button(id: "unvote_button")
        end
      end

      context "and voted before" do
        let!(:vote) { create :vote, author: user, question: }

        before do
          switch_to_host(organization.host)
          login_as user, scope: :user
          visit decidim_consultations.question_path(question)
        end

        it "has a disabled unvote button" do
          expect(page).to have_button(id: "unvote_button")
          expect(page).to have_css("#unvote_button.disabled")
        end
      end
    end
  end

  context "when active consultation" do
    let(:consultation) { create(:consultation, :active, organization:) }
    let(:user) { create :user, :confirmed, organization: }

    context "and guest user" do
      before do
        switch_to_host(organization.host)
        visit decidim_consultations.question_path(question)
      end

      it "Page contains a vote button" do
        expect(page).to have_button(id: "vote_button")
        expect(page).not_to have_link(id: "vote_button")
      end

      it "Page do not contains an unvote button" do
        expect(page).not_to have_button(id: "unvote_button")
      end
    end

    context "and authenticated user" do
      let!(:response) { create :response, question: }

      context "and never voted before" do
        before do
          switch_to_host(organization.host)
          login_as user, scope: :user
          visit decidim_consultations.question_path(question)
        end

        it "Page contains a vote button" do
          expect(page).to have_link(id: "vote_button")
        end

        it "unvote button appears after voting" do
          click_link(id: "vote_button")
          click_button translated(response.title)
          click_button "Confirm"
          expect(page).to have_button(id: "unvote_button")
        end
      end

      context "and voted before" do
        let!(:vote) do
          create :vote, author: user, question:, response:
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
          expect(page).to have_link(id: "vote_button")
        end
      end
    end
  end

  context "when verification is required" do
    let(:consultation) { create(:consultation, :active, organization:) }
    let(:user) { create :user, :confirmed, organization: }
    let!(:response) { create :response, question: }
    let(:permissions) do
      {
        vote: {
          authorization_handlers: {
            "dummy_authorization_handler" => { "options" => {} }
          }
        }
      }
    end

    before do
      organization.available_authorizations = ["dummy_authorization_handler"]
      organization.save!
      question.create_resource_permission(permissions:)
    end

    context "when user is NOT verified" do
      before do
        switch_to_host(organization.host)
        login_as user, scope: :user
        visit decidim_consultations.question_path(question)
      end

      it "is NOT able to vote" do
        within ".question-vote-cabin", match: :first do
          click_button I18n.t("decidim.questions.vote_button.verification_required")
        end
        expect(page).to have_css("#authorizationModal", visible: :visible)
      end
    end

    context "when user IS verified" do
      before do
        handler_params = { user: }
        handler_name = "dummy_authorization_handler"
        handler = Decidim::AuthorizationHandler.handler_for(handler_name, handler_params)

        Decidim::Authorization.create_or_update_from(handler)

        switch_to_host(organization.host)
        login_as user, scope: :user
        visit decidim_consultations.question_path(question)
      end

      it "IS able to vote" do
        expect(page).to have_link(id: "vote_button")
        click_link(id: "vote_button")
        click_button translated(response.title)
        click_button "Confirm"
        expect(page).to have_button(id: "unvote_button")
      end
    end
  end
end
