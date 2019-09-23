# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Consultations
    describe MultipleVoteQuestion do
      let(:subject) { described_class.new(forms) }

      let(:organization) { create :organization }
      let(:consultation) { create :consultation, organization: organization }
      let(:question) { create :question, :multiple, consultation: consultation }
      let(:user) { create :user, organization: organization }
      let(:response) { create :response, question: question }
      let(:decidim_consultations_response_id) { response.id }
      let(:attributes) do
        {
          decidim_consultations_response_id: decidim_consultations_response_id
        }
      end

      let(:form1) do
        VoteForm
          .from_params(attributes)
          .with_context(current_user: user, current_question: question)
      end

      let(:form2) do
        VoteForm
          .from_params(attributes)
          .with_context(current_user: user, current_question: question)
      end

      let(:form3) do
        VoteForm
          .from_params(attributes)
          .with_context(current_user: user, current_question: question)
      end

      let(:forms) do
        [form1, form2, form3]
      end

      context "when user votes too few options" do
        let(:forms) do
          [form1]
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

        it "increases the response counter by three" do
          expect do
            subject.call
            response.reload
          end.to change(response, :votes_count).by(3)
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
