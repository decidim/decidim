# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Sortitions
    describe SortitionSearch do
      subject { described_class.new(params).results }

      let(:component) { create(:component, manifest_name: "sortitions") }
      let(:default_params) { { component: component } }
      let(:params) { default_params }
      let(:participatory_process) { component.participatory_space }

      it_behaves_like "a resource search", :sortition
      it_behaves_like "a resource search with categories", :sortition

      describe "results" do
        describe "search_text filter" do
          let(:params) { default_params.merge(search_text: search_text) }
          let(:search_text) { "dog" }

          it "returns the sortitions containing the search in the title or the aditional info or or witnesses" do
            create_list(:sortition, 3, component: component)
            create(:sortition, title: { en: "A dog" }, component: component)
            create(:sortition, additional_info: { en: "There is a dog in the office" }, component: component)
            create(:sortition, witnesses: { en: "My dog was there" }, component: component)

            expect(subject.size).to eq(3)
          end
        end

        describe "state filter" do
          let!(:cancelled) { create(:sortition, :cancelled, component: component) }
          let!(:active) { create(:sortition, component: component) }
          let(:params) { default_params.merge(state: state) }

          context "when Cancelled" do
            let(:state) { "cancelled" }

            it "Returns sortitions with the given state" do
              expect(subject.size).to eq(1)
            end
          end

          context "when Active" do
            let(:state) { "active" }

            it "Returns sortitions with the given state" do
              expect(subject.size).to eq(1)
            end
          end

          context "when all" do
            let(:state) { "all" }

            it "Returns sortitions whatever its state is" do
              expect(subject.size).to eq(2)
            end
          end
        end
      end
    end
  end
end
