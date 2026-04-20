# frozen_string_literal: true

shared_examples "API updatable project" do
  context "when form is not valid" do
    let(:title_en) { nil }

    it "returns form error" do
      expect do
        execute_query(query, variables)
      end.to raise_error(StandardError)
    end
  end

  context "with unavailable taxonomy" do
    let!(:taxonomy_id) { 0 }

    it "returns form error" do
      expect do
        execute_query(query, variables)
      end.to raise_error(StandardError)
    end
  end

  it "updates the project and sets the attributes" do
    project = response["updateProject"]
    expect(project["id"]).to be_present
    expect(project["coordinates"]).to eq(
      { "longitude" => longitude, "latitude" => latitude }
    )
    expect(project["title"]["translation"]).to include(title_en)
    expect(project["description"]["translation"]).to include(description_en)
    expect(project["relatedProposals"]).to eq([{ "id" => proposal.id.to_s }])
    expect(project["budget_amount"]).to eq(budget_amount)
  end
end
