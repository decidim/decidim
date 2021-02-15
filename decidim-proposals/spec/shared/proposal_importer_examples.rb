# frozen_string_literal: true

shared_context "with proposal import data" do
  let(:expected_data) do
    [
      {
        title: {
          "en" => "Esse qui. Ut."
        },
        body: {
          "en" => "Aliquid in ut. Laboriosam consequatur consequatur. Unde dolorem omnis.
Et earum aut. Quis enim quis. Dolore corporis et. Quia vel ex."
        },
        component: current_component
      },
      {
        title: {
          "en" => "Nihil id."
        },
        body: {
          "en" => "Atque qui aut. Quia et incidunt. Qui nihil dolore.
Delectus asperiores nihil. Sapiente omnis culpa. Eos at voluptatem."
        },
        component: current_component
      },
      {
        title: {
          "en" => "Suspendisse lobortis"
        },
        body: {
          "en" => "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
        },
        component: current_component
      }
    ]
  end
end

shared_examples "proposal importer" do
  include_context "with proposal import data"

  describe "#collection" do
    it "creates a collection of creators" do
      expect(subject.collection.length).to be(3)

      # Check that produced data matches with expected data
      expected_data.each_with_index do |data, index|
        data.each do |key, value|
          expect(subject.collection[index].produce.send(key)).to eq(value)
        end
      end
    end
  end
end
