# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Core
    describe UserEntityInputSort, type: :graphql do
      include_context "with a graphql class type"
      let(:type_class) { Decidim::Api::QueryType }

      let(:current_user) { create(:user, organization: current_organization) }
      let(:user) { create(:user, :confirmed, organization: current_organization) }
      let(:other_user) { create(:user, :confirmed, organization: current_organization) }
      let!(:models) { [user, other_user] }

      context "when sorting by user id" do
        include_examples "collection has input sort", "users", "id"
      end

      context "when sorting by user name" do
        include_examples "collection has input sort", "users", "name"
      end

      context "when sorting by user nickname" do
        include_examples "collection has input sort", "users", "nickname"
      end
    end
  end
end
