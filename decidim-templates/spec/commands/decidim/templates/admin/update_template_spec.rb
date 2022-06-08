# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Templates
    module Admin
      describe UpdateTemplate do
        subject { described_class.new(template, form, user) }

        let(:organization) { create :organization }
        let(:user) { create :user, :admin, :confirmed, organization: organization }
        let(:template) { create :questionnaire_template, organization: organization }
        let(:name) { "test" }
        let(:description) { "description" }

        let(:form) do
          instance_double(
            TemplateForm,
            invalid?: invalid,
            valid?: !invalid,
            current_user: user,
            current_organization: organization,
            name: name,
            description: description
          )
        end
        let(:invalid) { false }

        context "when the form is not valid" do
          let(:invalid) { true }

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when the form is valid" do
          it "broadcasts ok" do
            expect { subject.call }.to broadcast(:ok)
          end

          it "update the template" do
            subject.call
            expect(template.name).to eq(name)
            expect(template.description).to eq(description)
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:perform_action!)
              .with(:update, template, user, {})
              .and_call_original

            expect { subject.call }.to change(Decidim::ActionLog, :count)
            action_log = Decidim::ActionLog.last
            expect(action_log.version).to be_present
          end
        end
      end
    end
  end
end
