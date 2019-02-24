# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe ValidateMobilePhone do
      let(:form_klass) { Decidim::Verifications::Sms::MobilePhoneForm }
      let(:current_user) { create(:user) }
      let(:form) { form_klass.from_params(mobile_phone_number: ::Faker::PhoneNumber.cell_phone) }
      let(:other_form) { form_klass.from_params(mobile_phone_number: "wadus") }
      let(:command) { described_class.new(form, current_user) }

      describe "User validates phone number" do
        context "when the user doesn't have a sms authorization" do
          context "when the user doesn't have any authorization" do
            it "broadcasts invalid" do
              expect { command.call }.to broadcast :invalid
            end
          end

          context "when the user have an authorization different from sms" do
            before do
              create(:authorization, name: "dummy_authorization_handler", user: current_user, granted_at: 2.seconds.ago)
            end

            it "broadcasts invalid" do
              expect { command.call }.to broadcast :invalid
            end
          end
        end

        context "when the user have an sms authorization" do
          context "and status is not ok" do
            before do
              create(:authorization, name: "sms", user: current_user)
            end

            it "broadcasts invalid" do
              expect { command.call }.to broadcast :invalid
            end
          end

          context "and status is ok" do
            context "and phone number differs from authorization phone number" do
              before do
                create(:authorization, name: "sms", user: current_user, unique_id: other_form.unique_id, granted_at: 2.seconds.ago)
              end

              it "broadcasts invalid" do
                expect { command.call }.to broadcast :invalid
              end
            end

            context "and phone number is the same as authorization phoe number" do
              let!(:frozen_test_metadata) { form.verification_metadata }

              before do
                create(:authorization, name: "sms", user: current_user, unique_id: form.unique_id, granted_at: 2.seconds.ago)
                allow(form).to receive(:verification_metadata).and_return(frozen_test_metadata)
              end

              it "broadcasts ok" do
                expect { command.call }.to broadcast(:ok, frozen_test_metadata)
              end
            end
          end
        end
      end
    end
  end
end
