# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Conferences
    describe CurrentComponent do
      let(:request) { double(params:, env:) }
      let(:params) { {} }
      let(:manifest) { Decidim.find_component_manifest("dummy") }
      let(:organization) do
        create(:organization)
      end
      let(:current_conference) { create(:conference, organization:) }
      let(:other_conference) { create(:conference, organization:) }
      let(:env) do
        { "decidim.current_organization" => organization }
      end

      subject { described_class.new(manifest) }

      context "when the params contain an conference id" do
        before do
          params["conference_slug"] = current_conference.id.to_s
        end

        context "when the params do not contain a component id" do
          it "does not match" do
            expect(subject.matches?(request)).to be(false)
          end
        end

        context "when the params contain a component id" do
          before do
            params["component_id"] = component.id.to_s
          end

          context "when the component does not belong to the conference" do
            let(:component) { create(:component, participatory_space: other_conference) }

            it "matches" do
              expect(subject.matches?(request)).to be(false)
            end
          end

          context "when the component belongs to the conference" do
            let(:component) { create(:component, participatory_space: current_conference) }

            it "matches" do
              expect(subject.matches?(request)).to be(true)
            end
          end
        end
      end

      context "when the params do not contain an conference id" do
        it "does not match" do
          expect { subject.matches?(request) }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "when the params contain a non existing conference id" do
        before do
          params["conference_slug"] = "99999999"
        end

        context "when there is no component" do
          it "does not match" do
            expect { subject.matches?(request) }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end

        context "when there is component" do
          before do
            params["component_id"] = "1"
          end

          it "does not match" do
            expect { subject.matches?(request) }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end
    end
  end
end
