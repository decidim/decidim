# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Debates
    describe CloseDebateEvent do
      describe "notification digest mail" do
        let!(:component) do
          create(:debates_component,
                 organization:,
                 participatory_space:,
                 name: generate_component_name(participatory_space.organization.available_locales, :debates))
        end

        let(:admin) { create(:user, :admin, organization:) }
        let!(:follow) { create(:follow, followable: record, user:) }
        let(:params) do
          {
            conclusions: "Example conclusion",
            id: record.id
          }
        end

        let!(:record) do
          create(
            :debate,
            component:,
            title: generate_localized_title(:debate_title),
            description: generate_localized_description(:debate_description),
            instructions: generate_localized_description(:debate_instructions)
          )
        end

        let(:form) { Decidim::Debates::Admin::CloseDebateForm.from_params(params).with_context(current_user: admin) }
        let!(:command) { Decidim::Debates::Admin::CloseDebate.new(form) }

        before do
          allow(command).to receive(:debate).and_return(record)
        end

        context "when daily notification mail" do
          let!(:user) { create(:user, organization:, notifications_sending_frequency: "daily") }

          it_behaves_like "notification digest mail"
        end

        context "when weekly notification mail" do
          let!(:user) { create(:user, organization:, notifications_sending_frequency: "weekly") }

          it_behaves_like "notification digest mail"
        end
      end
    end
  end
end
