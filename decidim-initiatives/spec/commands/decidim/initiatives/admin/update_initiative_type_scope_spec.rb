# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    module Admin
      describe UpdateInitiativeTypeScope do
        let(:form_klass) { InitiativeTypeScopeForm }

        context "when successfull update" do
          it_behaves_like "update an initiative type scope"
        end
      end
    end
  end
end
