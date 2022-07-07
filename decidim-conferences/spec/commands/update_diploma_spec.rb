# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe Admin::UpdateDiploma do
    describe "call" do
      let(:my_conference) { create :conference }
      let(:user) { create :user, :admin, :confirmed, organization: my_conference.organization }

      let(:params) do
        {
          conference: {
            id: my_conference.id,
            main_logo: upload_test_file(Decidim::Dev.test_file("avatar.jpg", "image/jpeg")),
            signature: upload_test_file(Decidim::Dev.test_file("avatar.jpg", "image/jpeg")),
            sign_date: 5.days.from_now,
            signature_name: "Signature name",
            errors: my_conference.errors
          }
        }
      end
      let(:context) do
        {
          current_organization: my_conference.organization,
          current_user: user,
          conference_id: my_conference.id
        }
      end
      let(:form) do
        Admin::DiplomaForm.from_params(params).with_context(context)
      end
      let(:command) { described_class.new(form, my_conference) }

      describe "when the form is not valid" do
        before do
          allow(form).to receive(:invalid?).and_return(true)
        end

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
        end

        it "doesn't update the diploma configuration" do
          command.call
          my_conference.reload

          expect(my_conference.signature_name).not_to eq("Signature name")
        end
      end

      describe "when the form is valid" do
        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "updates the conference diploma configuration" do
          expect { command.call }.to broadcast(:ok)
          my_conference.reload

          expect(my_conference.signature_name).to eq("Signature name")
        end

        it "traces the action", versioning: true do
          expect(Decidim.traceability)
            .to receive(:perform_action!)
            .with(:update_diploma, my_conference, user)
            .and_call_original

          expect { command.call }.to change(Decidim::ActionLog, :count)
          action_log = Decidim::ActionLog.last
          expect(action_log.version).to be_present
        end
      end
    end
  end
end
