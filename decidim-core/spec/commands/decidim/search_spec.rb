# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Search do
    describe "call" do
      let(:current_organization) { create(:organization) }

      context "whith resources from different organizations" do
        let(:other_organization) { create(:organization) }
        before do
          create(:searchable_rsrc, organization: current_organization, content_a: "Fight fire with fire")
          create(:searchable_rsrc, organization: other_organization, content_a: "Light my fire")
        end
        let(:term) { "fire" }

        it "returns resources only from current_organization" do
          described_class.call(term, current_organization) do
            on(:ok) do |results|
              expect(results.count).to eq(1)
              expect(results.first.organization).to eq(current_organization)
            end
            on(:invalid) { raise("Should not happen") }
          end
        end
      end

      context "when SearchRsrc is empty" do
        let(:term) { "whatever" }

        it "returns an empty list" do
          described_class.call(term, current_organization) do
            on(:ok) do |results|
              expect(results).to be_empty
            end
            on(:invalid) { raise("Should not happen") }
          end
        end
      end

      context "when 'term' param is empty" do
        let(:term) { "" }

        before do
          create(:searchable_rsrc, organization: current_organization)
        end
        it "returns some random results" do
          described_class.call(term, current_organization) do
            on(:ok) do |results|
              expect(results).not_to be_empty
            end
            on(:invalid) { raise("Should not happen") }
          end
        end
      end

      describe "when filtering" do
        let(:term) { "king nothing" }
        let(:scope) { create(:scope, organization: current_organization) }

        context "by resource type" do
          let(:rsrc_type) { "Decidim::Meetings::Meeting" }
          before do
            create(:searchable_rsrc, organization: current_organization, resource_type: rsrc_type, content_a: "Where's your crown king nothing?")
            create(:searchable_rsrc, organization: current_organization, resource_type: "Decidim::Proposals::Proposal", content_a: "Where's your crown king nothing?")
          end

          context "when resource_type is setted" do
            it "only return resources of the given type" do
              described_class.call(term, current_organization, 'resource_type' => rsrc_type) do
                on(:ok) do |results|
                  expect(results).not_to be_empty
                  expect(
                    results.all? { |r| r.resource_type == rsrc_type }
                  ).to be true
                end
                on(:invalid) { raise("Should not happen") }
              end
            end
          end

          context "when resource_type is blank" do
            it "should not apply resource_type filter" do
              described_class.call(term, current_organization, 'resource_type' => '') do
                on(:ok) do |results|
                  expect(results).not_to be_empty
                  expect(results.count).to eq 2
                end
                on(:invalid) { raise("Should not happen") }
              end
            end
          end
        end

        context "by scope" do
          before do
            create(:searchable_rsrc, organization: current_organization, scope: scope, content_a: "Where's your crown king nothing?")
            create(:searchable_rsrc, organization: current_organization, content_a: "Where's your crown king nothing?")
          end

          context "when scope is setted" do
            it "only return resources in the given scope" do
              described_class.call(term, current_organization, 'decidim_scope_id' => scope.id.to_s) do
                on(:ok) do |results|
                  expect(results.count).to eq 1
                  expect(
                    results.all? { |r| r.decidim_scope_id == scope.id }
                  ).to be true
                end
                on(:invalid) { raise("Should not happen") }
              end
            end
          end

          context "when scope is blank" do
            it "should not apply scope filter" do
              described_class.call(term, current_organization, 'decidim_scope_id' => '') do
                on(:ok) do |results|
                  expect(results).not_to be_empty
                  expect(results.count).to eq 2
                end
                on(:invalid) { raise("Should not happen") }
              end
            end
          end
        end
      end
    end
  end
end
