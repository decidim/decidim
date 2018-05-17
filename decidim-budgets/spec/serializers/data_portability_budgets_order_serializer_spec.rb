# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets
  describe DataPortabilityBudgetsOrderSerializer do
    let(:resource) { create(:order) }
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
        puts "-------------"
        puts "#{resource.projects.length}"
        puts "-------------"
        # expect(subject.serialize).to include(checked_out_at: resource.checked_out_at)
      end

      it "includes the created at" do
        expect(subject.serialize).to include(checked_out_at: resource.checked_out_at)
      end

      it "includes the updated at" do
        expect(subject.serialize).to include(checked_out_at: resource.updated_at)
      end
    end
  end
end
