# frozen_string_literal: true

shared_examples_for "has publishable input filter" do |filter, participatory_space_type|
  let(:query) { "query ($filter: #{filter}){ #{participatory_space_type}(filter: $filter) { id }}" }

  describe "not published before" do
    let(:variables) { { "filter" => { "publishedBefore": 2.days.ago.iso8601 } } }

    it "finds nothing " do
      expect(response[participatory_space_type.to_s]).to eq([])
    end
  end

  describe "published before" do
    let(:variables) { { "filter" => { "publishedBefore": 2.days.from_now.iso8601 } } }

    it "finds participatory process " do
      expect(response[participatory_space_type.to_s].first["id"]).to eq(model.id.to_s)
    end
  end

  describe "published since" do
    let(:variables) { { "filter" => { "publishedSince": 2.days.ago.iso8601 } } }

    it "finds the participatory process " do
      expect(response[participatory_space_type.to_s].first["id"]).to eq(model.id.to_s)
    end
  end

  describe "not published since" do
    let(:variables) { { "filter" => { "publishedSince": 2.days.from_now.iso8601 } } }

    it "finds nothing " do
      expect(response[participatory_space_type.to_s]).to eq([])
    end
  end

  describe "id" do
    it "finds participatory space " do
      expect(response[participatory_space_type.to_s].first["id"]).to eq(model.id.to_s)
    end
  end
end

shared_examples_for "has publishable input filter component" do |filter, component_type|

  describe "not published before" do
    let(:query) { "{ #{component_type}(filter: {publishedBefore: \"#{2.days.ago.to_date}\"}) { edges { node { id } } } }" }

    it "finds nothing " do
      ids = response[component_type.to_s]["edges"].map { |edge| edge["node"]["id"] }
      expect(ids).to eq([])
    end
  end

  describe "published before" do
    let(:query) { "{ #{component_type}(filter: {publishedBefore: \"#{2.days.from_now.to_date}\"}) { edges { node { id } } } }" }

    it "finds participatory process " do
      ids = response[component_type.to_s]["edges"].map { |edge| edge["node"]["id"] }
      replies_ids = models.map(&:id).map(&:to_s)
      expect(ids).to eq([replies_ids[2], replies_ids[1], replies_ids[0]])
    end
  end

  describe "not published since" do
    let(:query) { "{ #{component_type}(filter: {publishedSince: \"#{2.days.from_now.to_date}\"}) { edges { node { id } } } }" }

    it "finds nothing " do
      ids = response[component_type.to_s]["edges"].map { |edge| edge["node"]["id"] }
      expect(ids).to eq([])
    end
  end

  describe "published since" do
    let(:query) { "{ #{component_type}(filter: {publishedSince: \"#{2.days.ago.to_date}\"}) { edges { node { id } } } }" }

    it "finds participatory process " do
      ids = response[component_type.to_s]["edges"].map { |edge| edge["node"]["id"] }
      replies_ids = models.map(&:id).map(&:to_s)
      expect(ids).to eq([replies_ids[2], replies_ids[1], replies_ids[0]])
    end
  end
end
