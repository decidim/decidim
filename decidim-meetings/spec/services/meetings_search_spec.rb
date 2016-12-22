require "spec_helper"

describe Decidim::Meetings::MeetingsSearch do
  let(:current_feature) { create :feature }
  let(:scope1) { create :scope, organization: current_feature.organization }
  let(:scope2) { create :scope, organization: current_feature.organization }
  let(:parent_category) { create :category, participatory_process: current_feature.participatory_process }
  let(:subcategory) { create :subcategory, parent: parent_category }
  let!(:meeting1) do
    create(
      :meeting,
      feature: current_feature,
      start_time: 1.day.from_now,
      category: parent_category,
      scope: scope1
    )
  end
  let!(:meeting2) do
    create(
      :meeting,
      feature: current_feature,
      start_time: 2.day.from_now,
      category: subcategory,
      scope: scope2
    )
  end
  let(:external_meeting) { create :meeting }
  let(:default_params) { { feature_id: current_feature.id } }
  let(:params) { default_params }

  subject { described_class.new(params) }

  describe "base query" do
    context "when no feature_id is passed" do
      let(:params) { {} }

      it "raises an error" do
        expect{ subject.results }.to raise_error(StandardError, "Missing feature")
      end
    end

    context "when the fature does not exist" do
      let(:params) { { feature_id: current_feature.id + 100000 } }

      it "raises an error" do
        expect{ subject.results }.to raise_error(StandardError, "Missing feature")
      end
    end
  end

  describe "filters" do
    context "feature_id" do
      it "only returns meetings from the given feature" do
        external_meeting = create(:meeting)

        expect(subject.results).not_to include(external_meeting)
      end
    end

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
        let(:params) { default_params.merge(scope_id: [scope2.id, scope1.id]) }

        it "filters meetings by scope" do
          expect(subject.results).to match_array [meeting1,meeting2]
        end
      end
    end

    context "category_id" do
      context "when the given category has no subcategories" do
        let(:params) { default_params.merge(category_id: subcategory.id) }

        it "returns only meetings from the given category" do
          expect(subject.results).to eq [meeting2]
        end
      end

      context "when the given category has some subcategories" do
        let(:params) { default_params.merge(category_id: parent_category.id) }

        it "returns meetings from this category and its children's" do
          expect(subject.results).to match_array [meeting2, meeting1]
        end
      end
    end
  end

  context "pagination" do
    let(:params) do
      default_params.merge(
        per_page: 2
      )
    end

    it "filters the meetings per page" do
      create(:meeting, feature: current_feature)
      meetings = subject.results

      expect(meetings.total_pages).to eq(2)
      expect(meetings.total_count).to eq(3)
    end
  end
end
