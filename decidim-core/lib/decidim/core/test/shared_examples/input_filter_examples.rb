# frozen_string_literal: true

shared_examples_for "collection has before/since input filter" do |collection, field|
  context "when date is before the past" do
    let(:query) { %[{ #{collection}(filter: {#{field}Before: "#{2.days.ago.to_date}"}) { id } }] }

    it "finds nothing" do
      ids = response[collection].map { |item| item["id"] }
      expect(ids).to eq([])
    end
  end

  context "when date is before the future" do
    let(:query) { %[{ #{collection}(filter: {#{field}Before: "#{2.days.from_now.to_date}"}) { id } }] }

    it "finds the models " do
      ids = response[collection].map { |item| item["id"] }
      expect(ids).to match_array(models.map(&:id).map(&:to_s))
    end
  end

  context "when date is after the future" do
    let(:query) { %[{ #{collection}(filter: {#{field}Since: "#{2.days.from_now.to_date}"}) { id } }] }

    it "finds nothing " do
      ids = response[collection].map { |item| item["id"] }
      expect(ids).to eq([])
    end
  end

  context "when date is after the past" do
    let(:query) { %[{ #{collection}(filter: {#{field}Since: "#{2.days.ago.to_date}"}) { id } }] }

    it "finds the models " do
      ids = response[collection].map { |item| item["id"] }
      expect(ids).to match_array(models.map(&:id).map(&:to_s))
    end
  end
end

shared_examples_for "connection has before/since input filter" do |connection, field|
  context "when date is before the past" do
    let(:query) { %[{ #{connection}(filter: {#{field}Before: "#{2.days.ago.to_date}"}) { edges { node { id } } } }] }

    it "finds nothing" do
      ids = response[connection]["edges"].map { |edge| edge["node"]["id"] }
      expect(ids).to eq([])
    end
  end

  context "when date is before the future" do
    let(:query) { %[{ #{connection}(filter: {#{field}Before: "#{2.days.from_now.to_date}"}) { edges { node { id } } } }] }

    it "finds the models " do
      ids = response[connection]["edges"].map { |edge| edge["node"]["id"] }
      expect(ids).to match_array(models.map(&:id).map(&:to_s))
    end
  end

  context "when date is after the future" do
    let(:query) { %[{ #{connection}(filter: {#{field}Since: "#{2.days.from_now.to_date}"}) { edges { node { id } } } }] }

    it "finds nothing " do
      ids = response[connection]["edges"].map { |edge| edge["node"]["id"] }
      expect(ids).to eq([])
    end
  end

  context "when date is after the past" do
    let(:query) { %[{ #{connection}(filter: {#{field}Since: "#{2.days.ago.to_date}"}) { edges { node { id } } } }] }

    it "finds the models " do
      ids = response[connection]["edges"].map { |edge| edge["node"]["id"] }
      expect(ids).to match_array(models.map(&:id).map(&:to_s))
    end
  end
end

shared_examples_for "collection has hashtag input filter" do |collection|
  let(:query) { %[{ #{collection}(filter: { hashtag: "#{hashtag}" }) { id }}] }

  before do
    models.first.hashtag = "#someWeirdHashtag"
    models.first.save!
    models.second.hashtag = "#anotherWeirdHashtag"
    models.second.save!
  end

  context "when hashtag starts with #" do
    let(:hashtag) { "#someWeirdHashtag" }

    it "finds the model" do
      ids = response[collection].map { |item| item["id"] }
      expect(ids).to include(models.first.id.to_s)
      expect(ids).not_to include(models.second.id.to_s)
    end
  end

  context "when hashtag starts without #" do
    let(:hashtag) { "anotherWeirdHashtag" }

    it "finds the model" do
      ids = response[collection].map { |item| item["id"] }
      expect(ids).not_to include(models.first.id.to_s)
      expect(ids).to include(models.second.id.to_s)
    end
  end

  context "when hashtag is different" do
    let(:hashtag) { "someEvenWeirderHashtag" }

    it "does not find the model" do
      ids = response[collection].map { |item| item["id"] }
      expect(ids).not_to include(models.first.id.to_s)
      expect(ids).not_to include(models.second.id.to_s)
    end
  end
end
