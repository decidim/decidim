# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    module Admin
      describe ElectionsHelper do
        describe "#formatted_verification_types" do
          let(:election) { create(:election, verification_types: verification_types) }

          before do
            allow(helper).to receive(:election).and_return(election)
          end

          context "when verification_types is empty" do
            let(:verification_types) { [] }

            it "returns the no additional authorizations translation" do
              expect(helper.formatted_verification_types).to eq(I18n.t("internal_census_fields.no_additional_authorizations", scope: "decidim.elections.admin.census"))
            end
          end

          context "when verification_types are present" do
            let(:verification_types) { %w(email_authorization postal_letter) }

            it "returns translated, lowercase and comma-separated verification types" do
              translated_types = verification_types.map do |type|
                I18n.t("decidim.authorization_handlers.#{type}.name").downcase
              end.join(", ")

              expect(helper.formatted_verification_types).to eq(translated_types)
            end
          end
        end
      end
    end
  end
end
