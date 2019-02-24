# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe ValidateSmsCode do
      let(:form_klass) { Decidim::Verifications::Sms::ConfirmationForm }
      let(:form) { form_klass.from_params(form_params) }
      let(:form_params) { { "verification_code" => "123456" } }
      let(:verification_metadata) { form_params }
      let(:command) { described_class.new(form, verification_metadata) }

      describe "sms code validation" do
        context "when the verification_metadata and the params to initialize form equals" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast :ok
          end
        end

        context "when the verification_metadata is blank" do
          let(:command) { described_class.new(form, nil) }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast :invalid
          end
        end

        context "when the verification_metadata is different from params to initialize form" do
          let(:verification_metadata) { { verification_code: "wadus", code_sent_at: 20.seconds.ago } }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast :invalid
          end
        end
      end
    end
  end
end
