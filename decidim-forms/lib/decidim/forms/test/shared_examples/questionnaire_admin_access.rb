# frozen_string_literal: true

require "spec_helper"

shared_examples_for "questionnaire admin access" do
  context "when the user is not an admin" do
    let(:regular_user) { create(:user, :confirmed, organization:) }

    before do
      login_as regular_user, scope: :user
    end

    it_behaves_like "a 404 page" do
      visit manage_questions_path
    end
  end

  context "when the user is a process admin" do
    let(:process_admin) { create(:user, :confirmed, organization:) }
    let(:role) { create(:participatory_process_user_role, role: :admin, user: process_admin, participatory_process:) }

    it "allows access to the questionnaire" do
      login_as process_admin, scope: :user
      visit manage_questions_path

      expect(page).to have_current_path(manage_questions_path)
    end
  end

  context "when the user is an admin" do
    let(:admin) { create(:user, :admin, :confirmed, organization:) }

    it "allows access to the questionnaire" do
      login_as admin, scope: :user
      visit manage_questions_path

      expect(page).to have_current_path(manage_questions_path)
    end
  end
end
