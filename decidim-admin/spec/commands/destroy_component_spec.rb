require "spec_helper"
require "decidim/dummy_component_manifest"

module Decidim
  module Admin
    describe DestroyComponent do
      let(:participatory_process) { create :participatory_process }
      let(:component) { create(:component, participatory_process: participatory_process) }

      subject { described_class.new(component) }

      context "when everything is ok" do
        it "destroys the component" do
          subject.call
          expect(Component.where(id: component.id)).to_not exist
        end

        it "fires the hooks" do
          raise "PENDING"
        end
      end
    end
  end
end
