# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    module Admin
      describe UpdateQuestionStatus do
        subject { described_class.new(action, question) }

        let(:question) { create(:election_question) }
        let(:action) { :enable_voting }

        context "when action is invalid" do
          let(:action) { :invalid_action }

          it "broadcasts :invalid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when enabling voting" do
          it "sets start_at and broadcasts :ok" do
            expect { subject.call }.to broadcast(:ok)
            expect(question.reload.voting_enabled_at).to be_present
          end
        end

        context "when publishing results" do
          let(:action) { :publish_results }

          it "sets published_results_at" do
            expect { subject.call }.to broadcast(:ok)
            expect(question.reload.published_results_at).to be_present
          end
        end
      end
    end
  end
end
