# frozen_string_literal: true

require "spec_helper"

shared_examples_for "questionnaire admin access" do
  context "when the user is not authenticated" do
    before do
      sign_out user
    end

    it "redirects to the sign in page" do
      expect do
        visit manage_questions_path
      end.to redirect_to("/users/sign_in")
    end
  end

  context "when the user is not an admin" do
    let(:user) { create(:user, :confirmed, organization:) }

    it "redirects to the root page" do
      expect do
        visit manage_questions_path
      end.to redirect_to("/")
    end
  end

  context "when the user is a process admin" do
    let(:user) { create(:user, :confirmed, organization:) }
    let(:role) { create(:participatory_process_user_role, role: :admin, user:, participatory_process:) }

    it "allows access to the questionnaire" do
      visit manage_questions_path

      expect(page).to have_current_path(manage_questions_path)
    end
  end

  context "when the user is an admin" do
    let(:user) { create(:user, :admin, :confirmed, organization:) }

    it "allows access to the questionnaire" do
      visit manage_questions_path

      expect(page).to have_current_path(manage_questions_path)
    end
  end
end