# frozen_string_literal: true

shared_examples_for "has publishable input filter" do |filter, participatory_space_type|
  let!(:model) { create(:participatory_process, :published, organization: current_organization) }
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
    it "finds nothing " do
      expect(response[participatory_space_type.to_s].first["id"]).to eq(model.id.to_s)
    end
  end
end
