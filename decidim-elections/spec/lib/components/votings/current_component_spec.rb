# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Votings
    describe CurrentComponent do
      let(:request) { double(params: params, env: env) }
      let(:params) { {} }
      let(:manifest) { Decidim.find_component_manifest("dummy") }
      let(:organization) do
        create(:organization)
      end
      let(:current_voting) { create(:voting, organization: organization) }
      let(:other_voting) { create(:voting, organization: organization) }
      let(:env) do
        { "decidim.current_organization" => organization }
      end

      subject { described_class.new(manifest) }

      context "when the params contain a voting id" do
        before do
          params["voting_slug"] = current_voting.id.to_s
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

          context "when the component doesn't belong to the voting" do
            let(:component) { create(:component, participatory_space: other_voting) }

            it "matches" do
              expect(subject.matches?(request)).to be(false)
            end
          end

          context "when the component belongs to the voting" do
            let(:component) { create(:component, participatory_space: current_voting) }

            it "matches" do
              expect(subject.matches?(request)).to be(true)
            end
          end
        end
      end

      context "when the params don't contain an voting id" do
        it "doesn't match" do
          expect { subject.matches?(request) }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "when the params contain a non existing voting id" do
        before do
          params["voting_slug"] = "99999999"
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
