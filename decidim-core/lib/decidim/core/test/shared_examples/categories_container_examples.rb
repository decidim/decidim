# frozen_string_literal: true

require "spec_helper"

shared_examples_for "categories container interface" do
  describe "categories" do
    let!(:categories) { create_list(:category, 3, participatory_space: model) }
    let!(:subcategories) do
      categories.map { |cat| create_list(:subcategory, 3, parent: cat) }.flatten
    end
    let(:other_space) { create(:participatory_process, organization: model.organization) }
    let!(:other_categories) { create_list(:category, 3, participatory_space: other_space) }
    let(:category_ids) { [categories.map(&:id), subcategories.map(&:id)].flatten }
    let(:query) { "{ categories { id } }" }

    it "returns its categories" do
      ids = response["categories"].map { |cat| cat["id"].to_i }
      expect(ids).to match_array(category_ids)
      expect(ids).not_to include(*other_categories.map(&:id))
    end
  end
end
