# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    describe Election do
      subject { election }

      let(:election) { build(:election) }
      let(:organization) { election.component.organization }

      it { is_expected.to be_valid }
      it { is_expected.to act_as_paranoid }
      it { is_expected.to be_versioned }

      include_examples "has component"
      include_examples "resourceable"

      context "without a component" do
        let(:election) { build(:election, component: nil) }

        it { is_expected.not_to be_valid }
      end

      context "without a valid component" do
        let(:election) { build(:election, component: build(:component, manifest_name: "proposals")) }

        it { is_expected.not_to be_valid }
      end

      it "has an associated component" do
        expect(election.component).to be_a(Decidim::Component)
      end

      context "without a title" do
        let(:election) { build(:election, title: nil) }

        it { is_expected.not_to be_valid }
      end

      context "without a description" do
        let(:election) { build(:election, description: nil) }

        it { is_expected.to be_valid }
      end

      context "when votes exist" do
        let(:election) { create(:election, :with_questions) }
        let!(:vote) { create(:election_vote, question: election.questions.first, response_option: election.questions.first.response_options.first) }

        it "has many votes" do
          expect(subject.votes.count).to be_positive
          expect(subject.votes_count).to eq(subject.votes.count)
        end

        it "increments the votes count" do
          expect { create(:election_vote, question: election.questions.first, response_option: election.questions.first.response_options.second) }
            .to change(subject, :votes_count).by(1)
        end
      end

      describe "#manual_start?" do
        it "returns true when start_at is nil" do
          election.start_at = nil
          expect(election).to be_manual_start
        end

        it "returns false when start_at is present" do
          election.start_at = Time.current
          expect(election).not_to be_manual_start
        end
      end

      describe "#auto_start?" do
        it "returns true when start_at is present" do
          election.start_at = Time.current
          expect(election).to be_auto_start
        end

        it "returns false when start_at is nil" do
          election.start_at = nil
          expect(election).not_to be_auto_start
        end
      end

      describe "#started?" do
        it { is_expected.not_to be_started }

        context "when start_at is in the future" do
          let(:election) { build(:election, :scheduled) }

          it { is_expected.not_to be_started }
        end

        context "when start_at is in the past" do
          let(:election) { build(:election, :finished) }

          it { is_expected.to be_started }
        end
      end

      describe "#finished?" do
        it { is_expected.not_to be_finished }

        context "when in the future" do
          let(:election) { build(:election, :ongoing) }

          it { is_expected.not_to be_finished }
        end

        context "when in the past" do
          let(:election) { build(:election, :finished) }

          it { is_expected.to be_finished }
        end

        context "when question by question" do
          let(:election) { create(:election, :with_questions, :per_question) }

          it { is_expected.not_to be_finished }

          context "when finished" do
            let(:election) { create(:election, :with_questions, :per_question, :finished) }

            it { is_expected.to be_finished }
          end

          context "when ongoing" do
            let!(:election) { create(:election, :with_questions, :per_question, :ongoing) }

            it { is_expected.not_to be_finished }

            context "when some questions have finished" do
              before do
                election.questions.first.update!(published_results_at: 1.day.ago)
              end

              it { is_expected.not_to be_finished }
            end

            context "when all questions have finished" do
              before do
                election.questions.update_all(published_results_at: 1.day.ago) # rubocop:disable Rails/SkipsModelValidations
              end

              it { is_expected.to be_finished }
            end
          end
        end
      end

      describe "#ongoing?" do
        it { is_expected.not_to be_ongoing }

        context "when started" do
          let(:election) { build(:election, :ongoing) }

          it { is_expected.to be_ongoing }
        end

        context "when not started" do
          let(:election) { build(:election, :scheduled) }

          it { is_expected.not_to be_ongoing }
        end

        context "when vote finished" do
          let(:election) { build(:election, :finished) }

          it { is_expected.not_to be_ongoing }
        end
      end

      describe "#scheduled?" do
        it { is_expected.not_to be_scheduled }

        context "when unpublished with dates" do
          let(:election) { build(:election, :scheduled) }

          it { is_expected.not_to be_scheduled }
        end

        context "when published" do
          let(:election) { build(:election, :published, :scheduled) }

          it { is_expected.to be_scheduled }
        end
      end

      describe "#ready_to_publish_results?" do
        it { is_expected.not_to be_ready_to_publish_results }

        context "when already published" do
          let(:election) { build(:election, :published_results) }

          it { is_expected.not_to be_ready_to_publish_results }
        end

        context "when not published" do
          let(:election) { build(:election, :finished) }

          it { is_expected.not_to be_ready_to_publish_results }
        end

        context "when no questions" do
          let(:election) { create(:election, :published, :finished) }

          it { expect(subject).not_to be_ready_to_publish_results }
        end

        context "when published" do
          let(:election) { create(:election, :with_questions, :published, :finished) }

          it { is_expected.to be_ready_to_publish_results }

          context "when ongoing" do
            let(:election) { build(:election, :published, :ongoing) }

            it { is_expected.not_to be_ready_to_publish_results }
          end

          context "when in the future" do
            let(:election) { build(:election, :published, :scheduled) }

            it { is_expected.not_to be_ready_to_publish_results }
          end

          context "when question by question" do
            let(:election) { create(:election, :published, :scheduled, :per_question) }

            it { is_expected.not_to be_ready_to_publish_results }

            context "when questions" do
              let(:election) { create(:election, :published, :ongoing, :per_question) }
              let!(:question) { create(:election_question, :with_response_options, election:) }

              it { expect(subject).not_to be_ready_to_publish_results }

              context "when some questions enabled" do
                before do
                  election.questions.first.update!(voting_enabled_at: Time.current)
                end

                it { expect(subject).to be_ready_to_publish_results }
              end
            end
          end
        end
      end

      describe "#published?_results" do
        context "when realtime" do
          let(:election) { build(:election, :real_time) }

          it { is_expected.not_to be_published_results }

          context "when vote ongoing" do
            let(:election) { build(:election, :ongoing, :real_time) }

            it { is_expected.to be_published_results }
          end

          context "when vote finished" do
            let(:election) { build(:election, :finished, :real_time) }

            it { is_expected.to be_published_results }
          end
        end

        context "when after_end" do
          let(:election) { build(:election, :after_end) }

          it { is_expected.not_to be_published_results }

          context "when vote ongoing" do
            let(:election) { build(:election, :ongoing, :after_end) }

            it { is_expected.not_to be_published_results }
          end

          context "when vote finished" do
            let(:election) { build(:election, :finished, :after_end) }

            it { is_expected.not_to be_published_results }
          end

          context "when results published" do
            let(:election) { build(:election, :published_results, :after_end) }

            it { is_expected.to be_published_results }
          end
        end

        context "when per_question" do
          let(:election) { create(:election, :with_questions, :per_question) }

          it { is_expected.not_to be_published_results }

          context "when vote scheduled" do
            let(:election) { create(:election, :scheduled, :per_question) }

            it { is_expected.not_to be_published_results }
          end

          context "when vote ongoing" do
            let(:election) { create(:election, :with_questions, :ongoing, :per_question) }

            it { is_expected.not_to be_published_results }
          end

          context "when some questions have published results" do
            before do
              election.questions.first.update!(published_results_at: Time.current)
            end

            it { is_expected.not_to be_published_results }
          end

          context "when published questions are not enabled" do
            before do
              election.questions.first.update!(voting_enabled_at: nil, published_results_at: Time.current)
            end

            it { is_expected.not_to be_published_results }
          end
        end
      end

      describe "#status" do
        it { expect(subject.status).to eq(:unpublished) }

        context "when realtime" do
          let(:election) { build(:election, :published) }

          it { expect(subject.status).to eq(:scheduled) }

          context "when ongoing" do
            let(:election) { build(:election, :published, :ongoing) }

            it { expect(subject.status).to eq(:ongoing) }
          end

          context "when finished" do
            let(:election) { build(:election, :published, :finished) }

            it { expect(subject.status).to eq(:finished) }
          end

          context "when results published" do
            let(:election) { build(:election, :published, :published_results) }

            it { expect(subject.status).to eq(:finished) }
          end
        end
      end

      describe "associations" do
        it "has many questions" do
          election.save!
          create(:election_question, election:)
          expect(election.questions.count).to eq(1)
        end

        it "has many voters" do
          election.save!
          create(:election_voter, election:)
          expect(election.voters.count).to eq(1)
        end

        it "has many votes" do
          election.save!
          question = create(:election_question, :with_response_options, election:)
          create(:election_vote, question:, response_option: question.response_options.first)
          expect(election.votes.count).to eq(1)
        end

        context "when destroying" do
          before do
            election.save!
            create(:election_question, :with_response_options, election:)
            create(:election_voter, election:)
          end

          it "does not delete questions" do
            election.destroy!
            expect(election.questions.count).to eq(0)
          end

          it "does not delete voters" do
            election.destroy!
            expect(election.voters.count).to eq(0)
          end

          context "when votes exist" do
            before do
              create(:election_vote, question: election.questions.first, response_option: election.questions.first.response_options.first)
            end

            it "restricts deletion with error" do
              expect { election.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
              expect(election.reload).to be_persisted
            end
          end
        end
      end

      describe "results_availability enum" do
        it "accepts real_time, per_question, after_end" do
          %w(real_time per_question after_end).each do |val|
            election.results_availability = val
            expect(election.results_availability).to eq(val)
          end
        end

        it "raises error for invalid value" do
          expect { election.results_availability = "invalid" }.to raise_error(ArgumentError)
        end
      end

      describe "#presenter" do
        it "returns a presenter instance" do
          expect(election.presenter).to be_a(Decidim::Elections::ElectionPresenter)
        end
      end

      describe "#available_questions" do
        it "returns all questions when per_question is false" do
          expect(election.available_questions).to eq(election.questions)
        end

        it "returns enabled questions when per_question is true" do
          election.update!(results_availability: "per_question")
          expect(election.available_questions).to eq(election.questions.enabled)
        end
      end

      describe ".log_presenter_class_for" do
        it "returns the admin log presenter class" do
          expect(described_class.log_presenter_class_for(nil)).to eq(Decidim::Elections::AdminLog::ElectionPresenter)
        end
      end

      describe "questions are ordered by position" do
        let!(:second_question) { create(:election_question, election:, position: 2) }
        let!(:first_question) { create(:election_question, election:, position: 1) }

        it "returns questions ordered by position" do
          expect(election.questions).to eq([first_question, second_question])
        end
      end

      describe "#per_question?" do
        let(:election_with_per_question) { build(:election, :per_question) }
        let(:election_with_real_time) { build(:election, :real_time) }

        it "returns true when results_availability is per_question" do
          expect(election_with_per_question).to be_per_question
        end

        it "returns false when results_availability is not per_question" do
          expect(election_with_real_time).not_to be_per_question
        end
      end
    end
  end
end
