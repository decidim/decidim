# frozen_string_literal: true

require "spec_helper"

shared_examples_for "categorizable interface" do
  let!(:category) { create(:category, participatory_space: model.participatory_space) }

  before do
    model.update(category: category)
  end

  describe "category" do
    let(:query) { "{ category { id } }" }

    it "has a category" do
      expect(response).to include("category" => { "id" => category.id.to_s })
    end
  end
end
