# frozen_string_literal: true

require "spec_helper"

describe Decidim::Debates::DebateSearch do
  subject { described_class.new(params).results }

  let(:current_component) { create :component, manifest_name: "debates" }
  let(:parent_category) { create :category, participatory_space: current_component.participatory_space }
  let(:subcategory) { create :subcategory, parent: parent_category }
  let!(:debate1) do
    create(
      :debate,
      component: current_component,
      start_time: 1.day.from_now,
      category: parent_category
    )
  end
  let!(:debate2) do
    create(
      :debate,
      :with_author,
      component: current_component,
      start_time: 2.days.from_now,
      category: subcategory
    )
  end
  let(:external_debate) { create :debate }
  let(:component_id) { current_component.id }
  let(:organization_id) { current_component.organization.id }
  let(:default_params) { { component: current_component } }
  let(:params) { default_params }

  describe "base query" do
    context "when no component is passed" do
      let(:default_params) { { component: nil } }

      it "raises an error" do
        expect { subject }.to raise_error(StandardError, "Missing component")
      end
    end
  end

  describe "filters" do
    describe "component_id" do
      it "only returns debates from the given component" do
        external_debate = create(:debate)

        expect(subject).not_to include(external_debate)
      end
    end

    describe "search_text filter" do
      let(:params) { default_params.merge(search_text: search_text) }
      let(:search_text) { "dog" }

      before do
        debate1.title["en"] = "Do you like my dog?"
        debate1.save
      end

      it "searches the title or the description in i18n" do
        expect(subject).to eq [debate1]
      end
    end

    describe "origin filter" do
      let(:params) { default_params.merge(origin: origin) }

      context "when filtering official debates" do
        let(:origin) { "official" }

        it "returns only official debates" do
          expect(subject).to eq [debate1]
        end
      end

      context "when filtering citizen debates" do
        let(:origin) { "citizens" }

        it "returns only citizen debates" do
          expect(subject).to eq [debate2]
        end
      end
    end

    describe "category_id" do
      context "when the given category has no subcategories" do
        let(:params) { default_params.merge(category_id: subcategory.id) }

        it "returns only debates from the given category" do
          expect(subject).to eq [debate2]
        end
      end

      context "when the given category has some subcategories" do
        let(:params) { default_params.merge(category_id: parent_category.id) }

        it "returns debates from this category and its children's" do
          expect(subject).to match_array [debate2, debate1]
        end
      end

      context "when the category does not belong to the current component" do
        let(:external_category) { create :category }
        let(:params) { default_params.merge(category_id: external_category.id) }

        it "returns an empty array" do
          expect(subject).to eq []
        end
      end
    end

    describe "order_start_time" do
      context "when ordering ascending" do
        let(:params) { default_params.merge(order_start_time: "asc") }

        it "shows the upcoming debates first" do
          expect(subject).to eq([debate1, debate2])
        end
      end

      context "when ordering descending" do
        let(:params) { default_params.merge(order_start_time: "desc") }

        it "shows the latest debates first" do
          expect(subject).to eq([debate2, debate1])
        end
      end
    end
  end
end
