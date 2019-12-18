# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test"

module Decidim
  module Core
    describe ComponentInputSort, type: :graphql do
      include_context "with a graphql type"
      let(:type_class) { Decidim::ParticipatoryProcesses::ParticipatoryProcessType }

      let(:model) { create(:participatory_process, organization: current_organization) }
      let!(:proposal) { create(:proposal_component, :published, participatory_space: model) }
      let!(:dummy) { create(:component, :published, participatory_space: model) }


      context "when order by id ASC" do
        let(:query) {  %[{ components(order: {id: "ASC"}) { id } }] }

        it "returns all the components ordered" do
          response_ids = response["components"].map { |component| component["id"].to_i }
          ids = model.components.sort_by(&:id).map { | proposal_component | proposal_component.id.to_i }
          expect(response_ids).to eq(ids)
        end
      end

      context "when order by id DESC" do
        let(:query) {  %[{ components(order: {id: "DESC"}) { id } }] }

        it "returns all the components ordered" do
          response_ids = response["components"].map { |component| component["id"].to_i }
          ids = model.components.sort_by(&:id).reverse.map { | proposal_component | proposal_component.id.to_i }
          expect(response_ids).to eq(ids)
        end
      end

      context "when order by weight DESC" do
        let(:query) {  %[{ components(order: {weight: "DESC"}) { id } }] }
        before do
          proposal.weight = 3
          proposal.save!
          dummy.weight = 1
          dummy.save
        end

        it "returns all the components ordered" do
          response_ids = response["components"].map { |component| component["id"].to_i }
          ids = model.components.sort_by(&:weight).reverse.map { | proposal_component | proposal_component.id.to_i }
          expect(response_ids).to eq(ids)
        end
      end

      context "when order by weight ASC" do
        let(:query) {  %[{ components(order: {weight: "ASC"}) { id } }] }
        before do
          proposal.weight = 3
          proposal.save!
          dummy.weight = 1
          dummy.save
        end

        it "returns all the components ordered" do
          response_ids = response["components"].map { |component| component["id"].to_i }
          ids = model.components.sort_by(&:weight).map { | proposal_component | proposal_component.id.to_i }
          expect(response_ids).to eq(ids)
        end
      end

      context "when order by type ASC" do
        let(:query) {  %[{ components(order: {type: "ASC"}) { id } }] }

        it "returns all the component ordered" do
          response_ids = response["components"].map { |component| component["id"].to_i }
          ids = model.components.sort_by(&:manifest_name).map { | component | component.id.to_i }
          expect(response_ids).to eq(ids)
        end
      end

      context "when order by type DESC" do
        let(:query) {  %[{ components(order: {type: "DESC"}) { id } }] }

        it "returns all the component ordered" do
          response_ids = response["components"].map { |component| component["id"].to_i }
          ids = model.components.sort_by(&:manifest_name).reverse.map { | component | component.id.to_i }
          expect(response_ids).to eq(ids)
        end
      end

      context "when order by name ASC" do
        let(:query) {  %[{ components(order: {name: "ASC"}) { id } }] }

        it "returns all the component ordered" do
          response_ids = response["components"].map { |component| component["id"].to_i }
          ids = model.components.sort_by{|component| component.name[current_organization.default_locale]}.map { | component | component.id.to_i }
          expect(response_ids).to eq(ids)
        end
      end

      context "when order by name DESC" do
        let(:query) {  %[{ components(order: {name: "DESC"}) { id } }] }

        it "returns all the component ordered" do
          response_ids = response["components"].map { |component| component["id"].to_i }
          ids = model.components.sort_by{|component| component.name[current_organization.default_locale]}.reverse_each.map { | component | component.id.to_i }
          expect(response_ids).to eq(ids)
        end
      end

      context "when order by name and locale ASC" do
        let(:query) {  %[{ components(order: {name: "ASC", locale: "ca"}) { id } }] }

        it "returns all the component ordered" do
          response_ids = response["components"].map { |component| component["id"].to_i }
          ids = model.components.sort_by{|component| component.name["ca"]}.map { | component | component.id.to_i }
          expect(response_ids).to eq(ids)
        end
      end

      context "when order by name and locale DESC" do
        let(:query) {  %[{ components(order: {name: "DESC", locale: "ca"}) { id } }] }

        it "returns all the component ordered" do
          response_ids = response["components"].map { |component| component["id"].to_i }
          ids = model.components.sort_by{|component| component.name["ca"]}.reverse_each.map { | component | component.id.to_i }
          expect(response_ids).to eq(ids)
        end
      end

      context "when order by name and wrong locale DESC" do
        let(:query) {  %[{ components(order: {name: "DESC", locale: "de"}) { id } }] }

        it "returns all the component ordered" do
          expect{response}.to raise_exception(Exception)
        end
      end
    end
  end
end
