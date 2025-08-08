# frozen_string_literal: true

require "spec_helper"

shared_examples_for "categorizable interface" do
  let!(:category) { create(:category, participatory_space: model.participatory_space) }

  describe "category" do
    let(:query) { "{ category { id } }" }

    context "when model has category" do
      before do
        model.update(category:)
      end

      it "has a category" do
        expect(response).to include("category" => { "id" => category.id.to_s })
      end
    end

    context "when model has no category" do
      it "returns null" do
        expect(response).to include("category" => nil)
      end
    end
  end
end
