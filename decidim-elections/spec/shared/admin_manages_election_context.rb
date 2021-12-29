# frozen_string_literal: true

shared_context "when admin manages elections" do
  let(:manifest_name) { "elections" }

  include_context "when managing a component as an admin" do
    let(:admin_component_organization_traits) { [:secure_context] }
  end
end
