# frozen_string_literal: true
# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Votings
    module Admin
      describe MonitoringCommitteeValidatePollingStationClosure do
        subject { described_class.new(form, closure) }

        let(:closure) { create :ps_closure }
        let(:form) do
          double(
            invalid?: invalid,
            monitoring_committee_notes:
          )
        end
        let(:invalid) { false }
        let(:monitoring_committee_notes) { ::Faker::Lorem.paragraph }

        context "when everything is ok" do
          it "updates the monitoring_committee_notes and updated_at time" do
            expect(subject.call).to broadcast(:ok)

            closure.reload

            expect(closure.monitoring_committee_notes).to eq(monitoring_committee_notes)
            expect(closure.validated_at).to be_present
            expect(closure.validated_at).to be_kind_of(Date)
          end
        end

        context "when the form is not valid" do
          let(:invalid) { true }

          it "broadcasts invalid" do
            expect(subject.call).to broadcast(:invalid)
          end
        end
      end
    end
  end
end
