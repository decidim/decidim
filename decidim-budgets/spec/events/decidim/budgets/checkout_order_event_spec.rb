# frozen_string_literal: true

require "spec_helper"

describe Decidim::Budgets::CheckoutOrderEvent do
  let(:order) { create :order }
  let(:resource) { order.component }
  let(:component_url) { main_component_url(resource) }
  let(:event_name) { "decidim.events.budgets.order_checkout" }

  include_context "when a simple event"
  it_behaves_like "a simple event"

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to eq("Your vote has been validated on #{translated(resource.participatory_space.title)}")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro)
        .to eq("Your vote has been validated. You can always edit it if you like by clicking here: <a href='#{component_url}'>#{translated(resource.participatory_space.title)}")
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro)
        .to eq("Thank you for your participation")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title)
        .to eq("Your vote has been validated on <a href='#{component_url}'>#{translated(resource.participatory_space.title)}</a> You can always edit it if you like.")
    end
  end
end
