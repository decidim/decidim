# frozen_string_literal: true

require "spec_helper"

shared_examples_for "scopable interface" do
  let!(:scope) { create(:scope, organization: model.participatory_space.organization) }

  before do
    model.update(scope:)
  end

  describe "scope" do
    let(:query) { "{ scope { id } }" }

    it "has a scope" do
      expect(response).to include("scope" => { "id" => scope.id.to_s })
    end
  end
end
