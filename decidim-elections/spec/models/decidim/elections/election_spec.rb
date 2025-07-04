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

      describe "#vote_finished?" do
        it { is_expected.not_to be_vote_finished }

        context "when in the future" do
          let(:election) { build(:election, :ongoing) }

          it { is_expected.not_to be_vote_finished }
        end

        context "when in the past" do
          let(:election) { build(:election, :finished) }

          it { is_expected.to be_vote_finished }
        end

        context "when question by question" do
          let(:election) { create(:election, :with_questions, :per_question) }

          it { is_expected.not_to be_vote_finished }

          context "when finished" do
            let(:election) { create(:election, :with_questions, :per_question, :finished) }

            it { is_expected.to be_vote_finished }
          end

          context "when ongoing" do
            let!(:election) { create(:election, :with_questions, :per_question, :ongoing) }

            it { is_expected.not_to be_vote_finished }

            context "when some questions have finished" do
              before do
                election.questions.first.update!(published_results_at: 1.day.ago)
              end

              it { is_expected.not_to be_vote_finished }
            end

            context "when all questions have finished" do
              before do
                election.questions.update_all(published_results_at: 1.day.ago) # rubocop:disable Rails/SkipsModelValidations
              end

              it { is_expected.to be_vote_finished }
            end
          end
        end
      end

      describe "#ongoing?" do
        it { is_expected.not_to be_ongoing }

        context "when started" do
          let(:election) { build(:election, :started) }

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
          let(:election) { build(:election, :results_published) }

          it { is_expected.not_to be_ready_to_publish_results }
        end

        context "when not published" do
          let(:election) { build(:election, :finished) }

          it { is_expected.not_to be_ready_to_publish_results }
        end

        context "when published" do
          let(:election) { build(:election, :published, :finished) }

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
            let(:election) { create(:election, :published, :scheduled, results_availability: "per_question") }

            it { is_expected.not_to be_ready_to_publish_results }

            context "when questions enabled" do
              let(:election) { create(:election, :with_questions, :published, :ongoing, results_availability: "per_question") }

              it { expect(subject).to be_ready_to_publish_results }
            end

            context "when no questions enabled" do
              let(:election) { create(:election, :with_questions, :published, :ongoing, results_availability: "per_question") }

              before do
                election.questions.update_all(voting_enabled_at: nil) # rubocop:disable Rails/SkipsModelValidations
              end

              it { expect(subject).not_to be_ready_to_publish_results }
            end

            context "when some questions enabled" do
              let(:election) { create(:election, :with_questions, :published, :ongoing, results_availability: "per_question") }

              before do
                election.questions.first.update!(voting_enabled_at: Time.current)
              end

              it { expect(subject).to be_ready_to_publish_results }
            end
          end
        end
      end

      describe "#results_published?" do
        context "when realtime" do
          let(:election) { build(:election, results_availability: "real_time") }

          it { is_expected.not_to be_results_published }

          context "when vote ongoing" do
            let(:election) { build(:election, :ongoing, results_availability: "real_time") }

            it { is_expected.to be_results_published }
          end

          context "when vote finished" do
            let(:election) { build(:election, :finished, results_availability: "real_time") }

            it { is_expected.to be_results_published }
          end
        end

        context "when after_end" do
          let(:election) { build(:election, results_availability: "after_end") }

          it { is_expected.not_to be_results_published }

          context "when vote ongoing" do
            let(:election) { build(:election, :ongoing, results_availability: "after_end") }

            it { is_expected.not_to be_results_published }
          end

          context "when vote finished" do
            let(:election) { build(:election, :finished, results_availability: "after_end") }

            it { is_expected.not_to be_results_published }
          end

          context "when results published" do
            let(:election) { build(:election, :results_published, results_availability: "after_end") }

            it { is_expected.to be_results_published }
          end
        end

        context "when per_question" do
          let(:election) { create(:election, :with_questions, results_availability: "per_question") }

          it { is_expected.not_to be_results_published }

          context "when vote scheduled" do
            let(:election) { create(:election, :scheduled, results_availability: "per_question") }

            it { is_expected.not_to be_results_published }
          end

          context "when vote ongoing" do
            let(:election) { create(:election, :with_questions, :ongoing, results_availability: "per_question") }

            it { is_expected.not_to be_results_published }
          end

          context "when some questions have published results" do
            before do
              election.questions.first.update!(published_results_at: Time.current)
            end

            it { is_expected.not_to be_results_published }
          end

          context "when published questions are not enabled" do
            before do
              election.questions.first.update!(voting_enabled_at: nil, published_results_at: Time.current)
            end

            it { is_expected.not_to be_results_published }
          end
        end
      end

      describe "#current_status" do
        context "when realtime" do
          let(:election) { build(:election, results_availability: "real_time") }

          it { expect(subject.current_status).to eq(:scheduled) }

          context "when ongoing" do
            let(:election) { build(:election, :ongoing, results_availability: "real_time") }

            it { expect(subject.current_status).to eq(:ongoing) }
          end

          context "when finished" do
            let(:election) { build(:election, :finished, results_availability: "real_time") }

            it { expect(subject.current_status).to eq(:results_published) }
          end

          context "when results published" do
            let(:election) { build(:election, :results_published, results_availability: "real_time") }

            it { expect(subject.current_status).to eq(:results_published) }
          end
        end

        context "when after_end" do
          let(:election) { build(:election, results_availability: "after_end") }

          it { expect(subject.current_status).to eq(:scheduled) }

          context "when ongoing" do
            let(:election) { build(:election, :ongoing, results_availability: "after_end") }

            it { expect(subject.current_status).to eq(:ongoing) }
          end

          context "when finished" do
            let(:election) { build(:election, :finished, results_availability: "after_end") }

            it { expect(subject.current_status).to eq(:finished) }
          end

          context "when results published" do
            let(:election) { build(:election, :results_published, results_availability: "after_end") }

            it { expect(subject.current_status).to eq(:results_published) }
          end
        end

        context "when per_question" do
          let(:election) { create(:election, :with_questions, results_availability: "per_question") }

          it { expect(subject.current_status).to eq(:scheduled) }

          context "when ongoing" do
            let(:election) { create(:election, :with_questions, :ongoing, results_availability: "per_question") }

            it { expect(subject.current_status).to eq(:ongoing) }
          end

          context "when finished" do
            let(:election) { create(:election, :with_questions, :finished, results_availability: "per_question") }

            it { expect(subject.current_status).to eq(:finished) }
          end

          context "when results published" do
            let(:election) { create(:election, :with_questions, :results_published, results_availability: "per_question") }

            it { expect(subject.current_status).to eq(:scheduled) }
          end

          context "when some questions have published results" do
            before do
              election.questions.first.update!(published_results_at: Time.current)
            end

            it { expect(subject.current_status).to eq(:scheduled) }

            context "when finished" do
              let(:election) { create(:election, :with_questions, :finished, results_availability: "per_question") }

              it { expect(subject.current_status).to eq(:finished) }
            end

            context "when ongoing" do
              let(:election) { create(:election, :with_questions, :ongoing, results_availability: "per_question") }

              it { expect(subject.current_status).to eq(:ongoing) }
            end
          end

          context "when all questions have published results" do
            before do
              election.questions.update_all(published_results_at: Time.current) # rubocop:disable Rails/SkipsModelValidations
            end

            it { expect(subject.current_status).to eq(:results_published) }

            context "when finished" do
              let(:election) { create(:election, :with_questions, :finished, results_availability: "per_question") }

              it { expect(subject.current_status).to eq(:results_published) }
            end

            context "when ongoing" do
              let(:election) { create(:election, :with_questions, :ongoing, results_availability: "per_question") }

              it { expect(subject.current_status).to eq(:results_published) }
            end
          end
        end
      end

      describe "associations" do
        it "has many questions" do
          election.save!
          create(:election_question, election: election)
          expect(election.questions.count).to eq(1)
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
        let(:election_with_per_question) { build(:election, results_availability: "per_question") }
        let(:election_with_real_time) { build(:election, results_availability: "real_time") }

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
