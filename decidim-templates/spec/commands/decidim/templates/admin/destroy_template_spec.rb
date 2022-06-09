# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Templates
    module Admin
      describe DestroyTemplate do
        subject { described_class.new(template, user) }

        let(:organization) { create :organization }
        let(:user) { create :user, :admin, :confirmed, organization: organization }
        let(:template) { create :questionnaire_template, organization: organization }

        it "broadcasts ok" do
          expect { subject.call }.to broadcast(:ok)
        end

        it "destroy the template" do
          subject.call
          expect { template.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end

        it "traces the action", versioning: true do
          expect(Decidim.traceability)
            .to receive(:perform_action!)
            .with(:delete, template, user)
            .and_call_original

          expect { subject.call }.to change(Decidim::ActionLog, :count)
          action_log = Decidim::ActionLog.last
          expect(action_log.version).to be_present
        end
      end
    end
  end
end
