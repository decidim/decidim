# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe CurrentFeature do
    let(:request) { double(params: params, env: env) }
    let(:subject) { described_class.new(manifest) }
    let(:params) { {} }
    let(:manifest) { Decidim.find_feature_manifest("dummy") }

    context "when the env does not contain a current organization" do
      let(:env) do
        {}
      end

      it "matches" do
        expect(subject.matches?(request)).to eq(false)
      end
    end

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

      context "when the env contains a current participatory space" do
        let(:env) do
          super().merge("decidim.current_participatory_space" => current_participatory_process)
        end

        context "when there's no feature" do
          it "doesn't match" do
            expect(subject.matches?(request)).to eq(false)
          end
        end

        context "when the feature doesn't belong to the participatory space" do
          before do
            params["feature_id"] = feature.id.to_s
          end

          let(:feature) { create(:feature) }

          it "matches" do
            expect(subject.matches?(request)).to eq(false)
          end
        end

        context "when the feature belongs to the participatory space" do
          before do
            params["feature_id"] = feature.id.to_s
          end

          let(:feature) { create(:feature, participatory_space: current_participatory_process) }

          it "matches" do
            expect(subject.matches?(request)).to eq(true)
          end
        end
      end

      context "when the env doesn't contain a current participatory space" do
        it "doesn't match" do
          expect(subject.matches?(request)).to eq(false)
        end
      end
    end
  end
end
