# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    class FilterableFakeController < Decidim::ApplicationController
      include Decidim::Proposals::Admin::Filterable

      def example_method
        {
          new_filter: [:a, :b, :c]
        }
      end
    end

    describe FilterableFakeController do
      let(:organization) { create(:organization) }
      let(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
      let(:component) { create(:component, :with_one_step, participatory_space: participatory_process, manifest_name: "proposals") }
      let(:view) { controller.view_context }

      before do
        allow(controller).to receive(:current_organization).and_return(organization)
        allow(controller).to receive(:current_participatory_space).and_return(participatory_process)
        allow(controller).to receive(:current_component).and_return(component)
      end

      context "with default configuration including extra configuration registry" do
        let!(:default_configuration) do
          ::Decidim::AdminFilter.new(:proposals).build_for(controller)
        end

        before do
          Decidim::AdminFiltersRegistry.register :proposals do |configuration|
            configuration.add_filters(*example_method.keys)
            configuration.add_filters_with_values(**example_method)
          end
        end

        describe "#filters" do
          it "returns the list of defined filters including the existing filters and the custom items" do
            expect(controller.send(:filters)).to include(*default_configuration.filters)
            expect(controller.send(:filters)).to include(:new_filter)
          end
        end

        describe "#filters_with_values" do
          it "returns the hash of defined filters with values including the custom filters with values" do
            expect(controller.send(:filters_with_values)).to include(**default_configuration.filters_with_values)
            expect(controller.send(:filters_with_values)).to include(new_filter: [:a, :b, :c])
          end
        end
      end
    end
  end
end
