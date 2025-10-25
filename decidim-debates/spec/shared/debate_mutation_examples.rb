# frozen_string_literal: true

shared_examples "create debate mutation examples" do
  context "when creation is enabled" do
    it "creates a debate" do
      debate = response["createDebate"]
      expect(debate).to be_present
      expect(debate["id"]).to be_present
      expect(debate["title"]["translation"]).to eq(title)
      expect(debate["description"]["translation"]).to eq(description)
    end

    it "associates taxonomies with the debate" do
      debate = response["createDebate"]
      expect(debate["taxonomies"]).to be_present
      expect(debate["taxonomies"].length).to eq(1)
      expect(debate["taxonomies"].first["name"]["translation"]).to eq(taxonomy.name["en"])
    end

    context "without taxonomies" do
      let(:taxonomy_ids) { [] }

      it "creates a debate without taxonomies" do
        debate = response["createDebate"]
        expect(debate).to be_present
        expect(debate["taxonomies"]).to be_empty
      end
    end
  end
end
