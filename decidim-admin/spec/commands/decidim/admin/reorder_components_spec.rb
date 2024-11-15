# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe ReorderComponents do
    subject { described_class.new(participatory_process.components, order) }

    let(:participatory_process) { create(:participatory_process, :with_steps) }
    let!(:component_first) { create(:component, :published, participatory_space: participatory_process, weight: 1) }
    let!(:component_second) { create(:component, :published, participatory_space: participatory_process, weight: 2) }
    let!(:component_third) { create(:component, :published, participatory_space: participatory_process, weight: 3) }
    let(:components) { participatory_process.components }
    let(:order) { [component_third.id, component_second.id, component_first.id] }

    it "updates the order of the components" do
      expect { subject.call }.to change { components.map(&:reload).map(&:weight) }.from([1, 2, 3]).to([3, 2, 1])
    end
  end
end
