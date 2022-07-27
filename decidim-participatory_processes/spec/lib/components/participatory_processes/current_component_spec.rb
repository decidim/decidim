# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryProcesses
    describe CurrentComponent do
      subject { described_class.new(manifest) }

      let(:request) { double(params:, env:) }
      let(:params) { {} }
      let(:manifest) { Decidim.find_component_manifest("dummy") }

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

      context "when the params contain a participatory_process id" do
        before do
          params["participatory_process_slug"] = current_participatory_process.id.to_s
        end

        context "when the params don't contain a component id" do
          it "doesn't match" do
            expect(subject.matches?(request)).to be(false)
          end
        end

        context "when the params contain a component id" do
          before do
            params["component_id"] = component.id.to_s
          end

          context "when the component doesn't belong to the participatory process" do
            let(:component) { create(:component) }

            it "matches" do
              expect(subject.matches?(request)).to be(false)
            end
          end

          context "when the component belongs to the participatory process" do
            let(:component) { create(:component, participatory_space: current_participatory_process) }

            it "matches" do
              expect(subject.matches?(request)).to be(true)
            end
          end
        end
      end

      context "when the params don't contain a participatory process id" do
        it "doesn't match" do
          expect { subject.matches?(request) }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "when the params contain a non existing participatory process id" do
        before do
          params["participatory_process_slug"] = "99999999"
        end

        context "when there's no component" do
          it "doesn't match" do
            expect { subject.matches?(request) }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end

        context "when there's component" do
          before do
            params["component_id"] = "1"
          end

          it "doesn't match" do
            expect { subject.matches?(request) }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end
    end
  end
end
