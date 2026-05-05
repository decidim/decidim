# frozen_string_literal: true

require "spec_helper"

shared_examples_for "questionnaire admin access" do |denied_error:, allow_process_admin: true|
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

    it "leads to an error" do
      denied_response = case denied_error
                        when 403
                          page.status_code == 403 || page.has_content?("You are not authorized to perform this action")
                        when 404
                          page.status_code == 404 || page.has_content?("The page you are looking for cannot be found")
                        else
                          raise ArgumentError, "unsupported denied_error: #{denied_error.inspect}. Use 403 or 404"
                        end

      expect(denied_response).to be(true)
    end
  end

  if allow_process_admin
    context "when the user is a process admin" do
      let(:process_admin) { create(:process_admin, :confirmed, participatory_process:) }

      it "allows access to the questionnaire" do
        login_as process_admin, scope: :user
        visit manage_questions_path

        expect(page).to have_current_path(manage_questions_path)
      end
    end
  else
    context "when the user is a process admin", driver: :rack_test do
      let(:participatory_process) { create(:participatory_process, organization:) }
      let(:process_admin) { create(:process_admin, :confirmed, participatory_process:) }

      before do
        login_as process_admin, scope: :user

        allow(Rails.application).to \
          receive(:env_config).with(no_args).and_wrap_original do |m, *|
            m.call.merge(
              "action_dispatch.show_exceptions" => true,
              "action_dispatch.show_detailed_exceptions" => false
            )
          end

        visit manage_questions_path
      end

      it "denies access to the questionnaire" do
        denied_response = case denied_error
                          when 403
                            page.status_code == 403 || page.has_content?("You are not authorized to perform this action")
                          when 404
                            page.status_code == 404 || page.has_content?("The page you are looking for cannot be found")
                          else
                            raise ArgumentError, "unsupported denied_error: #{denied_error.inspect}. Use 403 or 404"
                          end

        expect(denied_response).to be(true)
      end
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
