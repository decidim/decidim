# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test/shared_examples/has_publishable_input_sort"

module Decidim
  module ParticipatoryProcesses
    describe ParticipatoryProcessInputSort, type: :graphql do
      include_context "with a graphql type"
      let(:type_class) { Decidim::Api::QueryType }

      include_examples "has publishable input sort", "ParticipatoryProcessSort", "participatoryProcesses"

      let(:query) { "query ($order:ParticipatoryProcessSort){ participatoryProcesses(order: $order) { id }}" }
      let!(:model) { create_list(:participatory_process, 3, :published, organization: current_organization) }
    
      describe "ordered by id asc" do
        let(:variables) { { "order" => { "id": "ASC" } } }
    
        it "finds processes ordered by id asc " do
          response_ids = response["participatoryProcesses"].map { |reply| reply["id"].to_i }
          replies_ids = model.sort_by(&:published_at).map(&:id)
          expect(response_ids).to eq(replies_ids)
        end
      end    

      describe "ordered by id desc" do
        let(:variables) { { "order" => { "id": "DESC" } } }
    
        it "finds processes ordered by id desc " do
          response_ids = response["participatoryProcesses"].map { |reply| reply["id"].to_i }
          replies_ids = model.sort_by(&:id).reverse!.map(&:id)
          expect(response_ids).to eq(replies_ids)
        end
      end  

      describe "ordered by start date asc" do
        let(:variables) { { "order" => { "startDate": "ASC" } } }
        before do
          model[0].start_date = 1.day.ago
          model[1].start_date = 2.day.ago
          model[2].start_date = 3.day.ago
        end

        it "finds processes ordered by start date asc " do
          response_ids = response["participatoryProcesses"].map { |reply| reply["id"].to_i }
          replies_ids = model.sort_by(&:start_date).map(&:id)
          expect(response_ids).to eq(replies_ids)
        end
      end
    
      describe "ordered by start date desc" do
        let(:variables) { { "order" => { "startDate": "DESC" } } }
        before do
          model[2].start_date = 1.day.ago
          model[1].start_date = 2.day.ago
          model[0].start_date = 3.day.ago
        end

        it "finds processes ordered by start date desc " do
          response_ids = response["participatoryProcesses"].map { |reply| reply["id"].to_i }
          expect(response_ids).to eq([model[2].id, model[1].id, model[0].id])
        end
      end    
    end
  end
end
