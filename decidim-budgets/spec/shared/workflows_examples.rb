# frozen_string_literal: true

shared_examples "includes base workflow features" do
  describe "#budgets" do
    subject { workflow.budgets }

    let(:independent_component) { create(:budgets_component, organization:) }
    let(:unpublished_component) { create(:budgets_component, published_at: nil, organization:) }

    it "counts only the component resources" do
      expect(subject).to match_array(Decidim::Budgets::Budget.where(component: budgets_component))
    end
  end
end

shared_examples "doesn't highlight any resource" do
  it "doesn't highlight any resource" do
    workflow.budgets.each do |resource|
      expect(subject).not_to be_highlighted(resource)
    end
  end

  it "doesn't have a highlighted resource" do
    expect(workflow.highlighted).to be_empty
  end
end

shared_examples "highlights a resource" do
  it "highlight only the given resource" do
    expect(workflow.highlighted).to match_array([highlighted_resource])

    expect(subject).to be_highlighted(highlighted_resource)

    workflow.budgets
            .reject { |resource| resource == highlighted_resource }
            .each do |resource|
      expect(subject).not_to be_highlighted(resource)
    end
  end
end

shared_examples "allows to vote in all resources" do
  it "allows to vote in every resource" do
    workflow.budgets.each do |resource|
      expect(subject).to be_vote_allowed(resource)
    end

    expect(workflow.allowed).to match_array(workflow.budgets)
  end

  it "has an allowed status for every resource" do
    workflow.budgets.each do |resource|
      expect(workflow.status(resource)).to eq(:allowed)
    end
  end
end

shared_examples "doesn't allow to vote in any resource" do
  it "doesn't allow to vote in any resource" do
    workflow.budgets.each do |resource|
      expect(subject).not_to be_vote_allowed(resource)
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
  it "has a progress status for the order resource" do
    expect(workflow.status(order_resource)).to eq(:progress)
  end

  it "has one order in progress" do
    expect(workflow.progress).to match_array([order_resource])
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
  it "has a voted status for the order resource" do
    expect(workflow.status(order_resource)).to eq(:voted)
  end

  it "doesn't have any order in progress" do
    expect(workflow.progress).to be_empty
  end

  it "has one voted order" do
    expect(workflow.voted).to match_array([order_resource])
  end
end
