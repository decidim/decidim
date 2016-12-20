require "spec_helper"

describe Decidim::Meetings::MeetingsSearch do
  let(:current_feature) { create :feature }
  let(:scope1) { create :scope, organization: current_feature.organization }
  let(:scope2) { create :scope, organization: current_feature.organization }
  let!(:meeting1) do
    create(
      :meeting,
      feature: current_feature,
      start_time: 1.day.from_now,
      scope: scope1
    )
  end
  let!(:meeting2) do
    create(
      :meeting,
      feature: current_feature,
      start_time: 2.day.from_now,
      scope: scope2
    )
  end
  let(:external_meeting) { create :meeting }
  let(:default_params) { { feature_id: current_feature.id } }

  subject { described_class.new(params) }

  describe "base query" do
    context "when no current_feature is passed" do
      let(:params) {}

      it "raises an error" do
        expect{ subject.results }.to raise_error(StandardError)
      end
    end
  end

  describe "filters" do
    context "order_start_time" do
      let(:params) { default_params.merge(order_start_time: order) }

      context "is :asc" do
        let(:order) { :asc }

        it "sorts the meetings by start_time asc" do
          expect(subject.results).to eq [meeting1, meeting2]
        end
      end

      context "is :desc" do
        let(:order) { :desc }

        it "sorts the meetings by start_time desc" do
          expect(subject.results).to eq [meeting2, meeting1]
        end
      end
    end

    context "scope_id" do
      context "when a single id is being sent" do
        let(:params) { default_params.merge(scope_id: scope1.id) }

        it "filters meetings by scope" do
          expect(subject.results).to eq [meeting1]
        end
      end

      context "when multiple ids are sent" do
        let(:params) { default_params.merge(scope_id: "#{scope2.id},#{scope1.id}") }

        it "filters meetings by scope" do
          expect(subject.results).to match_array [meeting1,meeting2]
        end
      end
    end
  end
end
