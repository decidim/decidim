# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe BreadcrumbHelper do
    describe "#render_schema_org_breadcrumb_list" do
      subject { helper.render_schema_org_breadcrumb_list(breadcrumb_items) }

      let(:breadcrumb_items) do
        [
          {
            label: "Processes",
            url: "/processes",
            active: true
          }
        ]
      end

      let(:participatory_process) { create(:participatory_process) }

      before do
        allow(helper).to receive(:current_organization).and_return(participatory_process.organization)
      end

      it "renders a schema.org event" do
        keys = JSON.parse(subject).keys
        expect(keys).to include("@context")
        expect(keys).to include("@type")
        expect(keys).to include("itemListElement")
      end
    end
  end
end
