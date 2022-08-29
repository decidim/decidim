# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Consultations
    describe UnvoteQuestion do
      subject { described_class.new(question, user) }

      let(:organization) { create :organization }
      let(:consultation) { create :consultation, organization: }
      let(:question) { create :question, consultation: }
      let(:response) { create :response, question: }
      let(:user) { create :user, organization: }
      let!(:vote) { create :vote, author: user, question:, response: }

      context "when user unvotes the question" do
        it "broadcasts ok" do
          expect { subject.call }.to broadcast :ok
        end

        it "removes the vote" do
          expect do
            subject.call
          end.to change(Vote, :count).by(-1)
        end

        it "decreases the question votes counter by one" do
          expect do
            subject.call
            question.reload
          end.to change(question, :votes_count).by(-1)
        end

        it "decreases the response votes counter by one" do
          expect do
            subject.call
            response.reload
          end.to change(response, :votes_count).by(-1)
        end
      end
    end
  end
end
