# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    module Admin
      describe CreateInitiativeTypeScope do
        let(:form_klass) { InitiativeTypeScopeForm }

        describe "Successfull creation" do
          it_behaves_like "create an initiative type scope"
        end

        describe "Attempt of creating duplicated typed scopes" do
          let(:organization) { create(:organization) }
          let(:initiative_type) { create(:initiatives_type, organization:) }
          let!(:initiative_type_scope) do
            create(:initiatives_type_scope, type: initiative_type)
          end
          let(:form) do
            form_klass
              .from_model(initiative_type_scope)
              .with_context(type_id: initiative_type.id, current_organization: organization)
          end
          let(:command) { described_class.new(form) }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast :invalid
          end
        end
      end
    end
  end
end
