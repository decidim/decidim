# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryProcesses
    describe ParticipatoryProcessDemocraticQualityStatsPresenter do
      subject { described_class.new(content_block, process) }

      let(:organization) { create(:organization) }
      let(:process) { create(:participatory_process, organization:) }
      let(:content_block) { double("content_block", settings: settings) }
      let(:settings) do
        double(
          migrant_groups_invited: 4.0,
          cultural_origins_participation: 3.0,
          functional_diversity_invited: 5.0,
          functional_diversity_participation: 4.0,
          relevance_percentage: 4.0,
          citizen_influence_level: 3.0,
          languages_count: 4.0,
          venue_accessibility: 5.0
        )
      end

      describe "#stats" do
        let!(:proposals_component) { create(:component, :published, participatory_space: process, manifest_name: :proposals) }
        let!(:meetings_component) { create(:component, :published, participatory_space: process, manifest_name: :meetings) }
        let!(:accountability_component) { create(:component, :published, participatory_space: process, manifest_name: :accountability) }

        it "returns a hash with all stats" do
          stats = subject.stats

          expect(stats).to include(:global_score, :precision, :automatic, :auto_evaluation)
          expect(stats[:precision]).to eq(2)
        end

        describe "automatic metrics" do
          describe "influence score" do
            context "when there are no proposals" do
              it "returns minimum score" do
                expect(subject.stats[:automatic][:influence]).to eq(1.0)
              end
            end

            context "when there are proposals" do
              let!(:proposals) { create_list(:proposal, 10, component: proposals_component) }

              context "with no accepted proposals" do
                it "returns minimum score" do
                  expect(subject.stats[:automatic][:influence]).to eq(1.0)
                end
              end

              context "with 30% accepted proposals" do
                before do
                  proposals.first(3).each do |p|
                    p.assign_state("accepted")
                    p.update!(state_published_at: Time.current)
                  end
                end

                it "returns score 2.5" do
                  expect(subject.stats[:automatic][:influence]).to eq(2.5)
                end
              end

              context "with 70% accepted proposals" do
                before do
                  proposals.first(7).each do |p|
                    p.assign_state("accepted")
                    p.update!(state_published_at: Time.current)
                  end
                end

                it "returns score 3.5" do
                  expect(subject.stats[:automatic][:influence]).to eq(3.5)
                end
              end
            end
          end

          describe "hybridization score" do
            context "when there is no meetings component" do
              before do
                meetings_component.destroy!
              end

              it "returns minimum score" do
                expect(subject.stats[:automatic][:hybridization]).to eq(0.0)
              end
            end

            context "when there are no meetings" do
              it "returns score based only on component presence" do
                expect(subject.stats[:automatic][:hybridization]).to eq(1.0)
              end
            end

            context "when there are different types of meetings" do
              let!(:online_meeting) { create(:meeting, :online, component: meetings_component) }
              let!(:in_person_meeting) { create(:meeting, :in_person, component: meetings_component) }
              let!(:hybrid_meeting) { create(:meeting, :hybrid, component: meetings_component) }

              it "returns higher score" do
                expect(subject.stats[:automatic][:hybridization]).to eq(4.0)
              end

              context "and meetings with proposals" do
                let!(:proposal) { create(:proposal, component: proposals_component) }

                before do
                  create(:resource_link,
                         name: "proposals_from_meeting",
                         from: proposal,
                         to: online_meeting)
                end

                it "returns maximum score" do
                  expect(subject.stats[:automatic][:hybridization]).to eq(5.0)
                end
              end
            end
          end

          describe "transparency score" do
            context "when there are no proposals or results" do
              it "returns minimum score" do
                expect(subject.stats[:automatic][:transparency]).to eq(1.0)
              end
            end

            context "with proposals and results" do
              let!(:proposals) { create_list(:proposal, 10, component: proposals_component) }
              let!(:results) { create_list(:result, 10, component: accountability_component) }

              context "with no answered proposals or completed results" do
                it "returns minimum score" do
                  expect(subject.stats[:automatic][:transparency]).to eq(1.0)
                end
              end

              context "with 50% answered proposals and completed results" do
                before do
                  proposals.first(5).each do |p|
                    p.assign_state("accepted")
                    p.update!(state_published_at: Time.current, answered_at: Time.current, answer: { en: "Accepted" })
                  end
                  results.first(5).each { |r| r.update(progress: 100) }
                end

                it "returns score 3.0" do
                  expect(subject.stats[:automatic][:transparency]).to eq(3.0)
                end
              end

              context "with all answered proposals and completed results" do
                before do
                  proposals.each do |p|
                    p.assign_state("accepted")
                    p.update!(state_published_at: Time.current, answered_at: Time.current, answer: { en: "Accepted" })
                  end
                  results.each { |r| r.update(progress: 100) }
                end

                it "returns maximum score" do
                  expect(subject.stats[:automatic][:transparency]).to eq(5.0)
                end
              end
            end
          end

          describe "traceability score" do
            context "when there are no proposals or meetings" do
              it "returns minimum score" do
                expect(subject.stats[:automatic][:traceability]).to eq(1.0)
              end
            end

            context "with proposals and meetings" do
              let!(:proposals) { create_list(:proposal, 10, component: proposals_component) }
              let!(:meetings) { create_list(:meeting, 10, :in_person, component: meetings_component) }
              let!(:results) { create_list(:result, 10, component: accountability_component) }
              let!(:budgets_component) { create(:component, :published, participatory_space: process, manifest_name: :budgets) }
              let!(:budget) { create(:budget, component: budgets_component) }
              let!(:project) { create(:project, budget:) }

              context "with linked resources" do
                before do
                  proposals.first(5).each do |proposal|
                    create(:resource_link, from: proposal, to: results.first, name: "linked_results")
                    create(:resource_link, from: project, to: proposal, name: "included_proposals")
                  end
                end

                it "returns higher score" do
                  expect(subject.stats[:automatic][:traceability]).to be_between(2.0, 4.0)
                end
              end

              context "with all resources linked and quality meetings" do
                before do
                  proposals.each do |proposal|
                    create(:resource_link, from: proposal, to: results.first, name: "linked_results")
                    create(:resource_link, from: project, to: proposal, name: "included_proposals")
                  end
                  meetings.each { |m| m.update(end_time: 2.hours.from_now) }
                end

                it "returns maximum score" do
                  expect(subject.stats[:automatic][:traceability]).to eq(5.0)
                end
              end
            end
          end
        end

        describe "auto evaluation metrics" do
          let(:auto_evaluation_stats) { subject.stats[:auto_evaluation] }

          it "calculates inclusiveness score" do
            expect(auto_evaluation_stats[:inclusiveness]).to eq(4.0)
          end

          it "calculates relevance score" do
            expect(auto_evaluation_stats[:relevance]).to eq(4.0)
          end

          it "calculates citizen influence score" do
            expect(auto_evaluation_stats[:citizen_influence]).to eq(3.0)
          end

          it "calculates accessibility score" do
            expect(auto_evaluation_stats[:accessibility]).to eq(4.5)
          end
        end

        describe "global score" do
          it "calculates the average of automatic and auto-evaluation metrics" do
            expect(subject.stats[:global_score]).to be_between(1.0, 5.0)
          end
        end
      end

      describe "#finished_survey?" do
        context "when all survey fields are filled" do
          it "returns true" do
            expect(subject.finished_survey?).to be true
          end
        end

        context "when some survey fields are not filled" do
          let(:settings) do
            double(
              migrant_groups_invited: -1,
              cultural_origins_participation: 3.0,
              functional_diversity_invited: 5.0,
              functional_diversity_participation: 4.0,
              relevance_percentage: 4.0,
              citizen_influence_level: 3.0,
              languages_count: 4.0,
              venue_accessibility: 5.0
            )
          end

          it "returns false" do
            expect(subject.finished_survey?).to be false
          end
        end
      end
    end
  end
end
