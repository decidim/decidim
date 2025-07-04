# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    module Admin
      describe UpdateElectionStatus do
        subject { described_class.new(action, election) }

        let(:organization) { create(:organization, available_locales: [:en]) }
        let(:component) { create(:elections_component, organization:) }
        let(:election) { create(:election, :with_token_csv_census, component:) }
        let(:action) { :start }

        context "when action is invalid" do
          let(:action) { :invalid_action }

          it "broadcasts :invalid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when starting the election" do
          it "sets start_at and broadcasts :ok" do
            expect { subject.call }.to broadcast(:ok)
            expect(election.reload.start_at).to be_present
          end
        end

        context "when ending the election" do
          let(:action) { :end }

          it "sets end_at and broadcasts :ok" do
            expect { subject.call }.to broadcast(:ok)
            expect(election.reload.end_at).to be_present
          end
        end

        context "when publishing results" do
          let(:action) { :publish_results }

          let(:election) { create(:election, :with_token_csv_census, results_availability: "after_end", component:, start_at: 1.hour.ago, end_at: 10.minutes.ago, published_at: 1.day.ago) }

          it "sets published_results_at" do
            expect { subject.call }.to broadcast(:ok)
            expect(election.reload.published_results_at).to be_present
          end
        end
      end
    end
  end
end
