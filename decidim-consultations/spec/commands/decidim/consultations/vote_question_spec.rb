# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Consultations
    describe VoteQuestion do
      subject { described_class.new(form) }

      let(:organization) { create :organization }
      let(:consultation) { create :consultation, organization: }
      let(:question) { create :question, consultation: }
      let(:user) { create :user, organization: }
      let(:response) { create :response, question: }
      let(:decidim_consultations_response_id) { response.id }
      let(:attributes) do
        {
          decidim_consultations_response_id:
        }
      end

      let(:form) do
        VoteForm
          .from_params(attributes)
          .with_context(current_user: user, current_question: question)
      end

      context "when user votes the question" do
        it "broadcasts ok" do
          expect { subject.call }.to broadcast :ok
        end

        it "creates a vote" do
          expect do
            subject.call
          end.to change(Vote, :count).by(1)
        end

        it "increases the votes counter by one" do
          expect do
            subject.call
            question.reload
          end.to change(question, :votes_count).by(1)
        end

        it "increases the response counter by one" do
          expect do
            subject.call
            response.reload
          end.to change(response, :votes_count).by(1)
        end
      end

      context "when user tries to vote twice" do
        let!(:vote) { create :vote, author: user, question: }

        it "broadcasts invalid" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end
    end
  end
end
