# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Sortitions
    describe FilteredSortitions do
      let(:organization) { create(:organization) }
      let(:component) { create(:sortition_component, organization:) }
      let(:other_component) { create(:sortition_component) }
      let!(:sortitions) { create_list(:sortition, 10, component:) }

      it "Includes all sortitions for the given component" do
        expect(described_class.for(component)).to include(*sortitions)
      end

      it "Do not includes sortitios from other components" do
        expect(described_class.for(other_component)).not_to include(*sortitions)
      end
    end
  end
end
