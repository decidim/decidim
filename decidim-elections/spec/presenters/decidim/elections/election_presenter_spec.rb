# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    describe ElectionPresenter, type: :helper do
      subject(:presenter) { described_class.new(election) }

      let(:organization) { create(:organization) }
      let(:participatory_process) { create(:participatory_process, organization:) }
      let(:component) { create(:elections_component, participatory_space: participatory_process) }

      let(:election) do
        create(:election,
               component: component,
               title: { en: "Test election" })
      end

      describe "#title" do
        it "returns the election title" do
          expect(presenter.title).to eq("Test election")
        end

        it "returns the translated title when all_locales is true" do
          expect(presenter.title(all_locales: true)).to eq("en" => "Test election")
        end
      end

      describe "#election_path" do
        it "returns the public path for the election" do
          allow(Decidim::ResourceLocatorPresenter).to receive(:new)
            .with(election)
            .and_return(double(path: "/elections/123"))

          expect(presenter.election_path).to eq("/elections/123")
        end
      end

      context "when election is nil" do
        let(:presenter) { described_class.new(nil) }

        it { expect(presenter.title).to be_nil }
        it { expect(presenter.election_path).to be_nil }
      end

      describe "#to_json" do
        let(:election) { create(:election, :published, :real_time, :ongoing, component:) }
        let!(:question) { create(:election_question, :with_response_options, election:) }
        let!(:vote) { create(:election_vote, question:, response_option: question.response_options.first, voter_uid: "voter1") }

        context "when admin is true" do
          subject(:json) { presenter.to_json(admin: true) }

          it "includes total_votes for each question" do
            question_json = json[:questions].find { |q| q[:id] == question.id }
            expect(question_json[:total_votes]).to eq(1)
            expect(question_json[:total_votes_text]).to eq("1 vote")
          end
        end

        context "when admin is false and results are published" do
          subject(:json) { presenter.to_json(admin: false) }

          it "includes total_votes for questions with published results" do
            question_json = json[:questions].find { |q| q[:id] == question.id }
            expect(question_json[:total_votes]).to eq(1)
            expect(question_json[:total_votes_text]).to eq("1 vote")
          end
        end

        context "when admin is false and results are not published" do
          let(:election) { create(:election, :published, :per_question, :ongoing, component:) }
          let!(:question) { create(:election_question, :with_response_options, election:, voting_enabled_at: Time.current, published_results_at: nil) }

          subject(:json) { presenter.to_json(admin: false) }

          it "does not include total_votes for questions without published results" do
            question_json = json[:questions].find { |q| q[:id] == question.id }
            expect(question_json).not_to have_key(:total_votes)
            expect(question_json).not_to have_key(:total_votes_text)
          end
        end
      end
    end
  end
end
