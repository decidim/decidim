# frozen_string_literal: true

require "spec_helper"

shared_examples_for "questionnaire admin access" do
  context "when the user is not an admin", driver: :rack_test do
    let(:regular_user) { create(:user, :confirmed, organization:) }
    let(:target_path) { manage_questions_path }

    before do
      login_as regular_user, scope: :user
    end

    before do
      allow(Rails.application).to \
        receive(:env_config).with(no_args).and_wrap_original do |m, *|
          m.call.merge(
            "action_dispatch.show_exceptions" => true,
            "action_dispatch.show_detailed_exceptions" => false
          )
        end

      visit target_path
    end

    it "leads to a 404" do
      expect(page).to have_content("The page you are looking for cannot be found")

      expect(page).to have_http_status(:not_found)

      expect(page).to have_current_path(target_path)
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
