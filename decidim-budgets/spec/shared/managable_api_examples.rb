# frozen_string_literal: true

shared_examples "a creatable API budget" do
  context "with admin user" do
    it_behaves_like "create budget mutation" do
      let!(:scope) { :admin }
    end
  end

  context "with normal user" do
    it "returns nil" do
      expect(response).to be_nil
    end
  end

  context "with api_user" do
    it_behaves_like "create budget mutation" do
      let!(:scope) { :api_user }
    end
  end
end

shared_examples "create budget mutation" do
  it "creates a new budget" do
    expect do
      execute_query("{ value }", {}).try(:[], "value")
    end.to change(Decidim::Budgets::Budget, :count).by(1)
  end

  it "assigns fields" do
    budget = response["component"]["budget"]["createBudget"]
    expect(budget["id"]).to be_present
    expect(budget["title"]["translation"]).to eq(title[:en])
    expect(budget["description"]["translation"]).to eq(description[:en])
    expect(budget["totalBudgett"]).to eq(total_budget)
  end
end
