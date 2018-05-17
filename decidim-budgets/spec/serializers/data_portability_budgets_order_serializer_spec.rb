# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets
  describe DataPortabilityBudgetsOrderSerializer do
    let(:resource) { create(:order, checked_out_at: Time.now) }
    let!(:projects) { create_list(:project, 1, component: component, budget: 25_000_000) }

    let(:subject) { described_class.new(resource) }

    describe "#serialize" do
      it "includes the id" do
        expect(subject.serialize).to include(id: resource.id)
      end

      it "includes the component" do
        expect(subject.serialize).to include(component: resource.component.name)
      end

      it "includes the checked out at" do
        expect(subject.serialize).to include(checked_out_at: resource.checked_out_at)
      end

      it "includes the projects" do
        expect(subject.serialize).to include(checked_out_at: resource.checked_out_at)
      end

      it "includes the created at" do
        expect(subject.serialize).to include(created_at: resource.created_at)
      end

      it "includes the updated at" do
        expect(subject.serialize).to include(updated_at: resource.updated_at)
      end
    end
  end
end
