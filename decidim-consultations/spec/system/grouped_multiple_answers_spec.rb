# frozen_string_literal: true

require "spec_helper"

describe "Grouped Multiple Answers Question", type: :system do
  let(:organization) { create(:organization) }
  let(:consultation) { create(:consultation, :active, organization:) }
  let(:question) { create :question, :multiple, :published, consultation: }
  let(:response_group) { create :response_group }
  let(:user) { create :user, :confirmed, organization: }

  context "when response is grouped" do
    let!(:response) { create :response, question:, response_group: }

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_consultations.question_question_multiple_votes_path(question)
    end

    it "has group title" do
      within ".form .card" do
        expect(page).to have_unchecked_field("vote_id_#{response.id}")
        expect(page).to have_i18n_content(response_group.title)
      end
    end
  end

  context "when response is not grouped" do
    let!(:response) { create :response, question: }

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_consultations.question_question_multiple_votes_path(question)
    end

    it "do not have group title" do
      within ".form .card" do
        expect(page).to have_unchecked_field("vote_id_#{response.id}")
        expect(page).not_to have_i18n_content(response_group.title)
      end
    end
  end
end
