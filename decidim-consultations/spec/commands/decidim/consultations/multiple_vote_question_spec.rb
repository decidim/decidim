# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Consultations
    describe MultipleVoteQuestion do
      subject { described_class.new(form, user) }

      let(:organization) { create :organization }
      let(:consultation) { create :consultation, organization: organization }
      let(:question) { create :question, :multiple, consultation: consultation }
      let(:user) { create :user, organization: organization }
      let(:response1) { create :response, question: question }
      let(:response2) { create :response, question: question }
      let(:response3) { create :response, question: question }
      let(:responses) { [response1.id, response2.id, response3.id] }
      let(:form) do
        MultiVoteForm
          .from_params(attributes)
          .with_context(current_question: question)
      end
      let(:attributes) do
        {
          responses: responses
        }
      end

      context "when user votes too few options" do
        let(:responses) do
          [response1.id]
        end

        it "broadcasts invalid" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end

      context "when user votes too much options" do
        before do
          question.max_votes = 2
        end

        it "broadcasts invalid" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end

      context "when user votes the right number of options" do
        it "broadcasts ok" do
          expect { subject.call }.to broadcast :ok
        end

        it "increases the participants counter by one" do
          subject.call
          expect(question.total_participants).to eq(1)
        end

        it "creates a vote" do
          expect do
            subject.call
          end.to change(Vote, :count).by(3)
        end

        it "increases the votes counter by three" do
          expect do
            subject.call
            question.reload
          end.to change(question, :votes_count).by(3)
        end

        it "increases a response counter by one" do
          expect do
            subject.call
            response1.reload
          end.to change(response1, :votes_count).by(1)
        end
      end

      context "when user tries to vote more than maximum" do
        let!(:vote) { create :vote, author: user, question: question }

        it "broadcasts invalid" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end
    end
  end
end
