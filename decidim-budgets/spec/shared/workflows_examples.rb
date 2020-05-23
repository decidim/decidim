# frozen_string_literal: true

shared_examples "includes base workflow features" do
  describe "#budgets" do
    subject { workflow.budgets }

    let(:independent_component) { create(:budget_component, organization: organization) }
    let(:unpublished_component) { create(:budget_component, published_at: nil, organization: organization, parent: budgets_group) }

    it "counts only children and published components" do
      expect(subject).to match_array(budgets_group.children - [unpublished_component])
    end
  end
end

shared_examples "doesn't highlight any component" do
  it "doesn't highlight any component" do
    workflow.budgets.each do |component|
      expect(subject).not_to be_highlighted(component)
    end
  end

  it "doesn't have a highlighted component" do
    expect(workflow.highlighted).to be_nil
  end
end

shared_examples "highlights a component" do
  it "highlight only the given component" do
    expect(workflow.highlighted).to eq(highlighted_component)

    expect(subject).to be_highlighted(highlighted_component)

    workflow.budgets
            .reject { |component| component == highlighted_component }
            .each do |component|
      expect(subject).not_to be_highlighted(component)
    end
  end
end

shared_examples "allows to vote in all components" do
  it "allows to vote in every component" do
    workflow.budgets.each do |component|
      expect(subject).to be_vote_allowed(component)
    end

    expect(workflow.allowed).to match_array(workflow.budgets)
  end

  it "has an allowed status for every component" do
    workflow.budgets.each do |component|
      expect(workflow.status(component)).to eq(:allowed)
    end
  end
end

shared_examples "doesn't allow to vote in any component" do
  it "doesn't allow to vote in any component" do
    workflow.budgets.each do |component|
      expect(subject).not_to be_vote_allowed(component)
    end
  end
end

shared_examples "doesn't have orders" do
  it "doesn't have any order in progress" do
    expect(workflow.progress).to be_empty
  end

  it "doesn't have any discardable order" do
    expect(workflow.discardable).to be_empty
  end

  it "doesn't have any order voted" do
    expect(workflow.voted).to be_empty
  end
end

shared_examples "has an in-progress order" do
  it "has a progress status for the order component" do
    expect(workflow.status(order_component)).to eq(:progress)
  end

  it "has one order in progress" do
    expect(workflow.progress).to match_array([order_component])
  end

  it "doesn't have any order voted" do
    expect(workflow.voted).to be_empty
  end
end

shared_examples "allow to discard all the progress orders" do
  it "allow to discard all the progress orders" do
    expect(workflow.discardable).to match_array(workflow.progress)
  end
end

shared_examples "has a voted order" do
  it "has a voted status for the order component" do
    expect(workflow.status(order_component)).to eq(:voted)
  end

  it "doesn't have any order in progress" do
    expect(workflow.progress).to be_empty
  end

  it "has one voted order" do
    expect(workflow.voted).to match_array([order_component])
  end
end
