require "spec_helper"

module Decidim
  describe CurrentComponent do
    let(:request) { double(params: params, env: env) }
    let(:subject) { described_class.new(request) }
    let(:params) { Hash.new }

    context "when the env contains a current organization" do
      let(:organization) do
        create(:organization)
      end

      let(:participatory_processes) do
        create_list(:participatory_process, 2, organization: organization)
      end

      let(:current_participatory_process) { participatory_processes.first }

      let(:env) do
        { "decidim.current_organization" => organization }
      end

      context "when the params contain a participatory process id" do
        before do
          params[:participatory_process_id] = current_participatory_process.id
        end

        context "when there's no component" do
          it "doesn't inject the component into the environment" do
            subject.call
            expect(env["decidim.current_component"]).to be_blank
          end
        end

        context "when the component doesn't belong to the participatory process" do
          before do
            params[:current_component_id] = component.id
          end

          let(:feature) { create(:feature) }
          let(:component) { create(:component, feature: feature) }

          it "injects the component into the environment" do
            subject.call
            expect(env["decidim.current_component"]).to be_blank
          end
        end

        context "when the component belongs to the participatory process" do
          before do
            params[:current_component_id] = component.id
          end

          let(:feature) { create(:feature, participatory_process: current_participatory_process) }
          let(:component) { create(:component, feature: feature) }

          it "injects the component into the environment" do
            subject.call
            expect(env["decidim.current_component"]).to eq(component)
          end
        end
      end

      context "when the params doesn't contain a participatory process id" do
        it "doesn't inject the component into the environment" do
          subject.call
          expect(env["decidim.current_component"]).to be_blank
        end
      end
    end
  end
end
