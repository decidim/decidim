# frozen_string_literal: true

shared_examples_for "has publishable input sort" do |order, participatory_space_type|
  let(:query) { "query ($order: #{order}){ #{participatory_space_type}(order: $order) { id }}" }
  let!(:model) { create_list(:participatory_process, 3, :published, organization: current_organization) }

  describe "ordered asc" do
    let(:variables) { { "order" => { "publishedAt": "ASC" } } }

    it "finds processes ordered asc " do
      response_ids = response[participatory_space_type.to_s].map { |reply| reply["id"].to_i }
      replies_ids = model.sort_by(&:published_at).map(&:id)
      expect(response_ids).to eq(replies_ids)
    end
  end

  describe "ordered desc" do
    let(:variables) { { "order" => { "publishedAt": "DESC" } } }

    it "finds processes ordered desc " do
      response_ids = response[participatory_space_type.to_s].map { |reply| reply["id"].to_i }
      expect(response_ids).to eq([model[2].id, model[1].id, model[0].id])
    end
  end
end
