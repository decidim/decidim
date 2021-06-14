# frozen_string_literal: true

shared_examples_for "a component query type" do
  it "implements ComponentInterface" do
    expect(described_class.ancestors).to include(Decidim::Core::ComponentInterface)
  end
end
