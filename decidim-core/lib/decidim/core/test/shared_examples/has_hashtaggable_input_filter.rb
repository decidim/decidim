# frozen_string_literal: true

shared_examples_for "has hashtaggable input filter" do |filter, participatory_space_type|
  let(:query) { "query ($filter: #{filter}){ #{participatory_space_type}(filter: $filter) { id }}" }

  let(:hashtag) { "someHashtag" }
  before do
    model.hashtag = "#someHashtag"
    model.save!
  end

  context "when hashtag starts with #" do
    let(:variables) { { "filter" => { "hashtag": "##{hashtag}" } } }

    it "finds the participatory space" do
      ids = response[participatory_space_type.to_s].map { |space| space["id"] }
      expect(ids).to include(model.id.to_s)
    end
  end

  context "when hashtag starts without #" do
    let(:variables) { { "filter" => { "hashtag": hashtag } } }

    it "finds the participatory space" do
      ids = response[participatory_space_type.to_s].map { |space| space["id"] }
      expect(ids).to include(model.id.to_s)
    end
  end

  context "when hashtag is different" do
    let(:variables) { { "filter" => { "hashtag": "#{hashtag}_" } } }

    it "does not find the participatory space" do
      ids = response[participatory_space_type.to_s].map { |space| space["id"] }
      expect(ids).not_to include(model.id.to_s)
    end
  end
end
