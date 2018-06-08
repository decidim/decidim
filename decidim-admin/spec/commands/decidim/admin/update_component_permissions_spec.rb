# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe UpdateComponentPermissions do
    let!(:participatory_process) { create(:participatory_process, :with_steps) }

    let!(:component) do
      create(
        :component,
        participatory_space: participatory_process,
        permissions: {
          "create" => {
            "authorization_handler_name" => "dummy_authorization_handler",
            "options" => { "thelma" => "louise" }
          }
        }
      )
    end

    let(:manifest) { component.manifest }

    let(:form) do
      double(
        valid?: valid,
        permissions: {
          "create" => double(
            authorization_handler_name: "dummy",
            options: { "perry" => "mason" }
          )
        }
      )
    end

    let(:expected_permissions) do
      {
        "create" => {
          "authorization_handler_name" => "dummy",
          "options" => { "perry" => "mason" }
        }
      }
    end

    describe "when valid" do
      let(:valid) { true }

      it "broadcasts :ok and updates the component" do
        expect do
          described_class.call(form, component)
        end.to broadcast(:ok)

        expect(component.permissions).to eq(expected_permissions)
      end

      it "fires the hooks" do
        results = {}

        manifest.on(:permission_update) do |component|
          results[:component] = component
        end

        described_class.call(form, component)

        component = results[:component]

        expect(component.permissions).to eq(expected_permissions)
      end
    end

    describe "when invalid" do
      let(:valid) { false }

      it "does not update the permissions" do
        expect do
          described_class.call(form, component)
        end.to broadcast(:invalid)

        component.reload
        expect(component.permissions).not_to eq(expected_permissions)
      end
    end
  end
end
