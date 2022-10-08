# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Templates
    module Admin
      describe DestroyQuestionnaireTemplate do
        let(:template) { create(:questionnaire_template) }
        let(:admin) { create(:user, :admin) }
        let!(:templatable) { template.templatable }

        it "destroy the templatable" do
          described_class.call(template, admin)
          expect { templatable.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end

        it "destroy the template" do
          described_class.call(template, admin)
          expect { template.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
