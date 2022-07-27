# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe CurrentComponent do
    let(:request) { double(params:, env:) }
    let(:params) { {} }
    let(:manifest) { Decidim.find_component_manifest("dummy") }

    subject { described_class.new(manifest) }

    context "when the env does not contain a current organization" do
      let(:env) do
        {}
      end

      it "matches" do
        expect(subject.matches?(request)).to be(false)
      end
    end

    context "when the env contains a current organization" do
      let(:organization) do
        create(:organization)
      end

      let(:participatory_processes) do
        create_list(:participatory_process, 2, organization:)
      end

      let(:current_participatory_process) { participatory_processes.first }

      let(:env) do
        { "decidim.current_organization" => organization }
      end

      context "when the env contains a current participatory space" do
        let(:env) do
          super().merge("decidim.current_participatory_space" => current_participatory_process)
        end

        context "when there's no component" do
          it "doesn't match" do
            expect(subject.matches?(request)).to be(false)
          end
        end

        context "when the component doesn't belong to the participatory space" do
          before do
            params["component_id"] = component.id.to_s
          end

          let(:component) { create(:component) }

          it "matches" do
            expect(subject.matches?(request)).to be(false)
          end
        end

        context "when the component belongs to the participatory space" do
          before do
            params["component_id"] = component.id.to_s
          end

          let(:component) { create(:component, participatory_space: current_participatory_process) }

          it "matches" do
            expect(subject.matches?(request)).to be(true)
          end
        end
      end

      context "when the env doesn't contain a current participatory space" do
        it "doesn't match" do
          expect(subject.matches?(request)).to be(false)
        end
      end
    end
  end
end
