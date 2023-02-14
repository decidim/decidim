# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe IconHelper do
    describe "#component_icon" do
      let(:component) do
        create(:component, manifest_name: :dummy)
      end

      describe "when the component has no icon" do
        before do
          allow(component.manifest).to receive(:icon).and_return(nil)
        end

        it "returns a fallback" do
          result = helper.component_icon(component)
          expect(result).to include("question-mark")
        end
      end

      describe "when the component has icon" do
        it "returns the icon" do
          result = helper.component_icon(component)
          expect(result).to eq <<~SVG.strip
            <svg class="icon external-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 36.02 36.02"><circle cx="18.01" cy="18.01" r="15.75" fill="none" stroke="#2ecc71" stroke-width="4"/><circle cx="18.01" cy="18.01" r="11.25" fill="none" stroke="#08BCD0" stroke-width="4"/></svg>
          SVG
        end

        context "with role attribute specified" do
          it "implements role attribute" do
            result = helper.component_icon(component, role: "img")
            expect(result).to eq <<~SVG.strip
              <svg class="icon external-icon" role="img" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 36.02 36.02"><circle cx="18.01" cy="18.01" r="15.75" fill="none" stroke="#2ecc71" stroke-width="4"/><circle cx="18.01" cy="18.01" r="11.25" fill="none" stroke="#08BCD0" stroke-width="4"/></svg>
            SVG
          end
        end

        context "with no role attribute specified" do
          it "doesn't implement role attribute" do
            result = helper.component_icon(component)
            expect(result).to eq <<~SVG.strip
              <svg class="icon external-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 36.02 36.02"><circle cx="18.01" cy="18.01" r="15.75" fill="none" stroke="#2ecc71" stroke-width="4"/><circle cx="18.01" cy="18.01" r="11.25" fill="none" stroke="#08BCD0" stroke-width="4"/></svg>
            SVG
          end
        end
      end

      describe "resource_icon" do
        let(:result) { helper.resource_icon(resource) }

        context "when it has a component" do
          let(:resource) { build :dummy_resource }

          it "renders the component icon" do
            expect(helper).to receive(:component_icon).with(resource.component, {})

            result
          end
        end

        context "when it has a manifest" do
          let(:resource) { build(:component, manifest_name: :dummy) }

          it "renders the manifest icon" do
            expect(helper).to receive(:manifest_icon).with(resource.manifest, {})

            result
          end
        end

        context "when it is a user" do
          let(:resource) { build :user }

          it "renders a person icon" do
            expect(result).to include("svg#icon-person")
          end
        end

        context "when the resource component and manifest are nil" do
          let(:resource) { build :dummy_resource }

          before do
            allow(resource).to receive(:component).and_return(nil)
          end

          it "renders a generic icon" do
            expect(result).to include("svg#icon-bell")
          end
        end

        context "when the manifest icon is nil" do
          let(:resource) { build(:component, manifest_name: :dummy) }

          before do
            allow(resource.manifest).to receive(:icon).and_return(nil)
          end

          it "renders a generic icon" do
            expect(result).to include("svg#icon-question-mark")
          end
        end

        context "and in other cases" do
          let(:resource) { "Something" }

          it "renders a generic icon" do
            expect(result).to include("svg#icon-bell")
          end
        end
      end
    end
  end
end
