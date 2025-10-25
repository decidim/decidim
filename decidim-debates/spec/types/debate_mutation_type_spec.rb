# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/mutation_context"

module Decidim
  module Debates
    describe CloseDebateType, type: :graphql do
      include_context "with a graphql class mutation"

      let(:root_klass) { DebateMutationType }
      let(:organization) { create(:organization, available_locales: [:en]) }
      let(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
      let(:debates_component) { create(:component, manifest_name: :debates, participatory_space: participatory_process) }
      let!(:model) { create(:debate, component: debates_component, author: current_user) }
      let(:conclusions) { Decidim::Faker::Localized.sentence(word_count: 15) }
      let(:component) { model.component }
      let(:variables) do
        {
          input: {
            attributes: {
              conclusions: conclusions
            }
          }
        }
      end
      let(:query) do
        <<~GRAPHQL
          mutation($input: CloseDebateInput!) {
            close(input: $input) {
              id
              conclusions { translation(locale: "en") }
              closedAt
            }
          }
        GRAPHQL
      end

      context "with admin user" do
        let!(:user_type) { :admin }

        before do
          allow(model).to receive(:closeable_by?).with(current_user).and_return(true)
        end

        it_behaves_like "close debate mutation examples"
      end

      context "with normal user who is not the author" do
        let!(:user_type) { :user }

        it "returns nil" do
          expect(response["close"]).to be_nil
        end
      end

      context "with debate author" do
        let!(:user_type) { :user }

        before do
          allow(model).to receive(:closeable_by?).with(current_user).and_return(true)
        end

        it_behaves_like "close debate mutation examples"
      end

      context "with api_user" do
        let!(:user_type) { :api_user }

        before do
          allow(model).to receive(:closeable_by?).with(current_user).and_return(true)
        end

        it_behaves_like "close debate mutation examples"
      end
    end
  end
end
