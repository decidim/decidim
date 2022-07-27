# frozen_string_literal: true

require "spec_helper"

describe "Consultation", type: :system do
  let!(:organization) { create(:organization) }
  let!(:consultation) { create(:consultation, :published, organization:) }
  let!(:user) { create :user, :confirmed, organization: }

  before do
    switch_to_host(organization.host)
  end

  it_behaves_like "editable content for admins" do
    let(:target_path) { decidim_consultations.consultation_path(consultation) }
  end

  context "when requesting the consultation path" do
    before do
      visit decidim_consultations.consultation_path(consultation)
    end

    it "Shows the basic consultation data" do
      expect(page).to have_i18n_content(consultation.title)
      expect(page).to have_i18n_content(consultation.subtitle)
      expect(page).to have_i18n_content(consultation.description)
    end

    context "when the consultation is unpublished" do
      let!(:consultation) do
        create(:consultation, :unpublished, organization:)
      end

      before do
        switch_to_host(organization.host)
      end

      it "redirects to sign in path" do
        visit decidim_consultations.consultation_path(consultation)
        expect(page).to have_current_path("/users/sign_in")
      end

      context "with signed in user" do
        let!(:user) { create(:user, :confirmed, organization:) }

        before do
          sign_in user, scope: :user
        end

        it "redirects to root path" do
          visit decidim_consultations.consultation_path(consultation)
          expect(page).to have_current_path("/")
        end
      end
    end

    context "when highlighted questions" do
      let!(:question) { create(:question, :published, consultation:, scope: consultation.highlighted_scope) }

      before do
        switch_to_host(organization.host)
        visit decidim_consultations.consultation_path(consultation)
      end

      it "Shows the highlighted questions section" do
        expect(page).to have_content("Questions from #{translated consultation.highlighted_scope.name}".upcase)
      end

      it "shows highlighted question details" do
        expect(page).to have_i18n_content(question.title)
        expect(page).to have_i18n_content(question.subtitle)
      end
    end

    context "when regular questions" do
      let!(:scope) { create(:scope, organization:) }
      let!(:question) { create(:question, :published, consultation:, scope:) }

      before do
        switch_to_host(organization.host)
        visit decidim_consultations.consultation_path(consultation)
      end

      it "Shows the regular questions section" do
        expect(page).to have_content("QUESTIONS FOR THIS CONSULTATION")
      end

      it "shows the scope name" do
        expect(page).to have_content(scope.name["en"].upcase)
      end

      it "shows the question details" do
        expect(page).to have_i18n_content(question.title)
        expect(page).to have_i18n_content(question.subtitle)
      end
    end

    context "when showing the button that links to the question" do
      let!(:question) { create(:question, :published, consultation:, scope: consultation.highlighted_scope) }

      context "when the user is not logged in" do
        before do
          switch_to_host(organization.host)
          visit decidim_consultations.consultation_path(consultation)
        end

        it "shows the `take part` button" do
          expect(page).to have_content("TAKE PART")
        end
      end

      context "when the user is logged in" do
        before do
          switch_to_host(organization.host)
          login_as user, scope: :user
        end

        it "shows the `take part` button if the user has not voted yet" do
          visit decidim_consultations.consultation_path(consultation)

          expect(page).to have_content("TAKE PART")
        end

        it "shows the `already voted` button if the user has already voted" do
          question.votes.create(author: user, response: Decidim::Consultations::Response.new)
          visit decidim_consultations.consultation_path(consultation)

          expect(page).to have_content("ALREADY VOTED")
        end
      end
    end
  end
end
