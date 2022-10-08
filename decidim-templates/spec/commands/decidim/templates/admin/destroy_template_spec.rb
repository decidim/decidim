# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Templates
    module Admin
      describe DestroyTemplate do
        let(:template) { create(:questionnaire_template) }
        let(:admin) { create(:user, :admin) }
        let!(:templatable) { template.templatable }

        it "destroy the template" do
          described_class.call(template, admin)
          expect { template.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
