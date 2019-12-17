# frozen_string_literal: true

shared_examples_for "has hashtaggable input filter" do |filter, participatory_space_type|
  let!(:model) { create(:participatory_process, :with_hashtag, organization: current_organization) }
  let(:query) { "query ($filter: #{filter}){ #{participatory_space_type}(filter: $filter) { id }}" }

  describe "hashtag" do
    let(:variables) { { "filter" => { "hashtag": model.hashtag } } }

    it "finds participatory space" do
      expect(response[participatory_space_type.to_s]).to eq(model.id)
    end
  end
end
