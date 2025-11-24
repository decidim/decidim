# frozen_string_literal: true

require "spec_helper"

describe FactoryBot do
  it "has 100% valid factories" do
    expect { described_class.lint(traits: true) }.not_to raise_error
  end

  described_class.factories.sort_by(&:name).each do |factory|
    context "when using the #{factory.name} factory" do
      it "generates a single organization" do
        expect { create(factory.name) }.to change(Decidim::Organization, :count).by(1)
      end

      context "when using a trait" do
        factory.defined_traits.collect(&:name).each do |trait|
          it ":#{trait}" do
            expect { create(factory.name, trait.to_sym) }.to change(Decidim::Organization, :count).by(1)
          end
        end
      end
    end
  end
end
