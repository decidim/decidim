# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe CurrentFeature do
    let(:request) { double(params: params, env: env) }
    let(:subject) { described_class.new(manifest) }
    let(:params) { {} }
    let(:manifest) { Decidim.find_feature_manifest("dummy") }

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
          params["participatory_process_id"] = current_participatory_process.id
        end

        context "when there's no feature" do
          it "doesn't inject the feature into the environment" do
            subject.matches?(request)
            expect(request.env["decidim.current_feature"]).to be_blank
          end
        end

        context "when the feature doesn't belong to the participatory process" do
          before do
            params["feature_id"] = feature.id
          end

          let(:feature) { create(:feature) }

          it "doesn't inject the feature into the environment" do
            subject.matches?(request)
            expect(request.env["decidim.current_feature"]).to be_blank
          end
        end

        context "when the feature belongs to the participatory process" do
          before do
            params["feature_id"] = feature.id
          end

          let(:feature) { create(:feature, participatory_process: current_participatory_process) }

          it "injects the feature into the environment" do
            subject.matches?(request)
            expect(request.env["decidim.current_feature"]).to eq(feature)
          end

          it "injects the participatory process into the environment" do
            subject.matches?(request)
            expect(request.env["decidim.current_participatory_process"]).to eq(current_participatory_process)
          end
        end
      end

      context "when the params doesn't contain a participatory process id" do
        it "doesn't inject the feature into the environment" do
          subject.matches?(request)
          expect(request.env["decidim.current_feature"]).to be_blank
        end

        it "doesn't inject the participatory process into the environment" do
          subject.matches?(request)
          expect(request.env["decidim.current_participatory_process"]).to be_blank
        end
      end
    end
  end
end
