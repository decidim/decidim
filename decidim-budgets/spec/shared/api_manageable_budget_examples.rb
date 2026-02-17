# frozen_string_literal: true

shared_examples "API updatable budget" do
  context "when updating a budget" do
    it "updates fields" do
      updated_budget = response["updateBudget"]
      expect(updated_budget["id"].to_i).to eq(model.id)
      expect(updated_budget["title"]["translation"]).to eq(title_en)
      expect(updated_budget["description"]["translation"]).to eq(description_en)
      expect(updated_budget["total_budget"]).to eq(total_budget)
    end

    context "when performing a partial update" do
      let(:variables) do
        {
          component_id: current_component.id,
          budget_id:,
          input: {
            attributes: {
              title: { "es" => "El título en español" },
              description: { en: description_en },
              totalBudget: total_budget
            }
          }
        }
      end

      it "updates only specified fields" do
        updated_budget = response["updateBudget"]
        expect(updated_budget["id"].to_i).to eq(model.id)
        expect(updated_budget["title"]["translation"]).to eq(translated(model.title))
      end
    end
  end

  context "when having invalid arguments" do
    context "when having invalid locale" do
      let(:variables) do
        {
          component_id: current_component.id,
          budget_id: model.id,
          input: {
            attributes: {
              title: { "en" => title_en, "tlh" => "Foo bar" },
              description: { en: description_en },
              totalBudget: total_budget
            }
          }
        }
      end

      it "raises an error" do
        expect { response }.to raise_error(Decidim::Api::Errors::InvalidLocaleError, /Invalid locale provided/)
      end
    end
  end
end

shared_examples "API creatable budget" do
  it "creates a new budget" do
    expect do
      execute_query(query, variables)
    end.to change(Decidim::Budgets::Budget, :count).by(1)
  end

  it "assigns fields" do
    budget = response["createBudget"]
    expect(budget["id"]).to be_present
    expect(budget["title"]["translation"]).to eq(title_en)
    expect(budget["description"]["translation"]).to eq(description_en)
    expect(budget["total_budget"]).to eq(total_budget)
  end
end

shared_examples "API creatable project" do
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

  it "creates the project and sets the attributes" do
    project = response["createProject"]
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
