# frozen_string_literal: true

shared_examples_for "has publishable input sort" do |order, participatory_space_type|
  let(:query) { "query ($order: #{order}){ #{participatory_space_type}(order: $order) { id }}" }

  describe "ordered asc" do
    let(:variables) { { "order" => { "publishedAt": "ASC" } } }

    it "finds participatory space ordered asc " do
      response_ids = response[participatory_space_type.to_s].map { |reply| reply["id"].to_i }
      replies_ids = model.sort_by(&:published_at).map(&:id)
      expect(response_ids).to eq(replies_ids)
    end
  end

  describe "ordered desc" do
    let(:variables) { { "order" => { "publishedAt": "DESC" } } }

    it "finds participatory space ordered desc " do
      response_ids = response[participatory_space_type.to_s].map { |reply| reply["id"].to_i }
      expect(response_ids).to eq([model[2].id, model[1].id, model[0].id])
    end
  end
end

shared_examples_for "has publishable input sort in component" do |_order, component_type|
  describe "ordered asc" do
    let(:query) { "{ #{component_type}(order: {publishedAt: \"ASC\"}) { edges { node { id } } } }" }

    it "finds components ordered asc " do
      ids = response[component_type.to_s]["edges"].map { |edge| edge["node"]["id"] }
      replies_ids = models.sort_by(&:published_at).map(&:id).map(&:to_s)
      expect(ids).to eq(replies_ids)
    end
  end

  describe "ordered desc" do
    let(:query) { "{ #{component_type}(order: {publishedAt: \"DESC\"}) { edges { node { id } } } }" }

    it "finds components ordered desc " do
      ids = response[component_type.to_s]["edges"].map { |edge| edge["node"]["id"] }
      expect(ids).to eq([models[2].id.to_s, models[1].id.to_s, models[0].id.to_s])
    end
  end
end
