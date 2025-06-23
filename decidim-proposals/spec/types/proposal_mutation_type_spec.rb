# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Proposals
    describe ProposalMutationType, type: :graphql do
      include_context "with a graphql type and authenticated user"

      let(:model) { create(:proposal) }
      let(:state) { %w(accepted evaluating rejected).sample }
      let(:answer_en) { ::Faker::Lorem.paragraph }
      let(:answer_fi) { ::Faker::Lorem.paragraph }
      let(:answer_sv) { ::Faker::Lorem.paragraph }
      let(:component) { model.component }

      let(:query) do
        %(
          {
            answer(
              state: "#{state}",
              answerContent: {
                en: "#{answer_en}",
                fi: "#{answer_fi}",
                sv: "#{answer_sv}"
              }
            ){
                id
                state
              }
          }
        )
      end

      context "with admin user" do
        it_behaves_like "manage proposal mutation examples" do
          let!(:scope) { :admin }
        end
      end

      context "with normal user" do
        it "returns nil" do
          expect(response).to be_nil
        end
      end

      context "with api_user" do
        it_behaves_like "manage proposal mutation examples" do
          let!(:scope) { :api_user }
        end
      end
    end
  end
end
