# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/mutation_context"

module Decidim
  module Debates
    describe UpdateDebateType, type: :graphql do
      include_context "with a graphql class mutation"

      let(:root_klass) { DebateMutationType }
      let(:organization) { create(:organization, available_locales: [:en]) }
      let(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
      let(:debate_component) { create(:component, manifest_name: "debates", participatory_space: participatory_process) }
      let(:debate_author) { create(:user, organization:) }
      let!(:model) { create(:debate, author: debate_author, component: debate_component) }
      let(:title) { "Updated title" }
      let(:description) { "Updated description" }
      let(:taxonomies) { create_list(:taxonomy, 2, :with_parent, organization:) }
      let(:taxonomy_ids) { [] }
      let(:component) { model.component }
      let(:variables) do
        {
          input: {
            attributes: {
              title:,
              description:,
              taxonomyIds: taxonomy_ids
            }
          }
        }
      end
      let(:query) do
        <<~GRAPHQL
          mutation($input: UpdateDebateInput!) {
            update(input: $input) {
              id
              title { translation(locale: "en") }
              description { translation(locale: "en") }
            }
          }
        GRAPHQL
      end

      context "with admin user" do
        it_behaves_like "manage debate mutation examples" do
          let!(:user_type) { :admin }
          let!(:debate_author) { user }
        end
      end

      context "with normal user" do
        it "returns nil" do
          expect(response["update"]).to be_nil
        end
      end

      context "with api_user" do
        it_behaves_like "manage debate mutation examples" do
          let!(:user_type) { :api_user }
          let!(:debate_author) { user }
        end
      end

      context "when user is the debate author" do
        let!(:user_type) { :user }
        let!(:debate_author) { user }

        it "updates the debate" do
          update = response["update"]
          expect(update).to be_present
          expect(update["title"]["translation"]).to eq(title)
          expect(update["description"]["translation"]).to eq(description)
        end
      end
    end
  end
end
