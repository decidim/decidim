# frozen_string_literal: true

shared_examples "API updatable budget" do
  it "updates fields" do
    updated_budget = response["component"]["updateBudget"]
    expect(updated_budget["id"].to_i).to eq(budget.id)
    expect(updated_budget["title"]["translation"]).to eq(title_en)
    expect(updated_budget["description"]["translation"]).to eq(description_en)
    expect(updated_budget["total_budget"]).to eq(total_budget)
  end
end

shared_examples "API creatable budget" do
  it "creates a new budget" do
    expect do
      execute_query(query, variables)
    end.to change(Decidim::Budgets::Budget, :count).by(1)
  end

  it "assigns fields" do
    budget = response["component"]["createBudget"]
    expect(budget["id"]).to be_present
    expect(budget["title"]["translation"]).to eq(title_en)
    expect(budget["description"]["translation"]).to eq(description_en)
    expect(budget["total_budget"]).to eq(total_budget)
  end
end

shared_examples "API deletable budget" do
  it "deletes the budget" do
    expect(budget.deleted_at).to be_nil
    expect do
      execute_query(query, variables)
    end.to change(Decidim::Budgets::Budget, :count).by(-1)
    expect(budget.reload.deleted_at).not_to be_nil
  end
end

shared_examples "API creatable project" do
  context "when form is not valid" do
    let(:title_en) { nil }

    it "retrurns form error" do
      expect do
        execute_query(query, variables)
      end.to raise_error(StandardError)
    end
  end

  context "with unavailable taxonomy" do
    let!(:taxonomy_id) { 0 }

    it "retrurns form error" do
      expect do
        execute_query(query, variables)
      end.to raise_error(StandardError)
    end
  end

  it "creates the project and sets the attributes" do
    project = response["component"]["budget"]["createProject"]
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
