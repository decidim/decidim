# frozen_string_literal: true

require "spec_helper"

describe "Question", type: :system do
  let(:organization) { create(:organization) }
  let(:consultation) { create(:consultation, :published, organization: organization) }
  let(:question) { create :question, consultation: consultation }

  context "when shows question information" do
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

    it "Shows the technical data" do
      expect(page).to have_i18n_content(question.promoter_group)
      expect(page).to have_i18n_content(question.scope.name)
      expect(page).to have_i18n_content(question.participatory_scope)
      expect(page).to have_i18n_content(question.question_context)

      click_button("Read more")

      expect(page).to have_i18n_content(question.what_is_decided)
    end
  end

  context "when finished consultations" do
    context "and published results" do
      let(:consultation) { create :consultation, :finished, :published, :published_results, organization: organization }
      let(:response) { create :response, question: question }
      let!(:vote) { create :vote, question: question, response: response }

      before do
        switch_to_host(organization.host)
        visit decidim_consultations.question_path(question)
      end

      it "Has the results" do
        expect(page).to have_content("RESULTS")
        expect(page).to have_i18n_content(response.title)
        expect(page).to have_content(response.votes_count)
      end
    end
  end
end
