# frozen_string_literal: true

require "spec_helper"

module Decidim::Elections
  describe ElectionSearch do
    subject { described_class.new(params) }

    let(:current_component) { create :component, manifest_name: "elections" }
    let!(:active_election) do
      create(
        :election,
        :ongoing,
        component: current_component,
        description: Decidim::Faker::Localized.literal("Chambray chia selvage hammock health goth.")
      )
    end
    let!(:upcoming_election) do
      create(
        :election,
        :upcoming,
        component: current_component,
        description: Decidim::Faker::Localized.literal("Selfies kale chips taxidermy adaptogen.")
      )
    end
    let!(:finished_election) do
      create(
        :election,
        :finished,
        component: current_component,
        description: Decidim::Faker::Localized.literal("Tacos gentrify celiac mixtape.")
      )
    end
    let(:external_election) { create :election }
    let(:component_id) { current_component.id }
    let(:organization_id) { current_component.organization.id }
    let(:default_params) { { component: current_component, organization: current_component.organization } }
    let(:params) { default_params }

    describe "base query" do
      context "when no component is passed" do
        let(:default_params) { { component: nil } }

        it "raises an error" do
          expect { subject.results }.to raise_error(StandardError, "Missing component")
        end
      end
    end

    describe "filters" do
      context "with component_id" do
        it "only returns elections from the given component" do
          external_election = create(:election)

          expect(subject.results).not_to include(external_election)
        end
      end

      context "with status" do
        let(:params) { default_params.merge(state: state) }

        context "when active" do
          let(:state) { ["active"] }

          it "only returns active elections" do
            expect(subject.results).to match_array [active_election]
          end
        end

        context "when finished" do
          let(:state) { ["finished"] }

          it "only returns finished elections" do
            expect(subject.results).to match_array [finished_election]
          end
        end

        context "when upcoming" do
          let(:state) { ["upcoming"] }

          it "only returns upcoming elections" do
            expect(subject.results).to match_array [upcoming_election]
          end
        end
      end

      context "with search_text" do
        let(:params) { default_params.merge(search_text: "mixtape") }

        it "show only the election containing the search_text" do
          expect(subject.results).to include(finished_election)
          expect(subject.results.length).to eq(1)
        end
      end
    end
  end
end
