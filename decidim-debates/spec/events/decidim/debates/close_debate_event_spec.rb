# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Debates
    describe CloseDebateEvent do
      let!(:component) { create(:debates_component, organization:, participatory_space:) }
      let(:admin) { create(:user, :admin, organization:, notifications_sending_frequency: "daily", locale: "en") }
      let!(:user) { create(:user, organization:, notifications_sending_frequency: "daily", locale: "en") }
      let!(:follow) { create(:follow, followable: record, user:) }
      let(:params) do
        {
          conclusions: "testi testi",
          id: record.id
        }
      end

      let!(:record) do
        create(
          :debate,
          component:,
          title: { en: "Event notifier" },
          description: { en: "This debate is for testing purposes" },
          instructions: { en: "Use this debate for testing" }
        )
      end

      let(:form) { Decidim::Debates::Admin::CloseDebateForm.from_params(params).with_context(current_user: admin) }
      let!(:command) { Decidim::Debates::Admin::CloseDebate.new(form) }

      before do
        allow(command).to receive(:debate).and_return(record)
      end

      it_behaves_like "event notification"
    end
  end
end
