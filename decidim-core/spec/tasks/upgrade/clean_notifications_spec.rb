# frozen_string_literal: true

require "spec_helper"

describe "rake decidim:upgrade:clean:notifications", type: :task do
  context "when executing task" do
    it "does not throw exceptions keys" do
      expect { task.execute }.not_to raise_exception
    end
  end

  context "when there are no errors" do
    let!(:notification) { create_list(:notification, 8, created_at: 2.days.ago) }

    it "avoid removing entries" do
      expect { task.execute }.not_to change(Decidim::Notification, :count)
    end
  end

  context "when there are errors" do
    let!(:notifications) { create_list(:notification, 8, created_at: 2.days.ago) }
    let!(:invalid_entries) { notifications.collect(&:id).sample(4) }

    context "when missing manifests" do
      context "when missing event class" do
        it "removes entries" do
          Decidim::Notification.where(id: invalid_entries).update_all(event_class: "Decidim::Dev::MissingEvent") # rubocop:disable Rails/SkipsModelValidations

          expect(Decidim::Notification.count).to eq(8)

          expect { task.execute }.to change(Decidim::Notification, :count).by(-invalid_entries.size)

          expect(Decidim::Notification.where(id: invalid_entries).length).to eq(0)
        end
      end

      context "when missing resource types" do
        it "removes entries" do
          Decidim::Notification.where(id: invalid_entries).update_all(decidim_resource_type: "Decidim::Dev::MissingEvent") # rubocop:disable Rails/SkipsModelValidations

          expect(Decidim::Notification.count).to eq(8)

          expect { task.execute }.to change(Decidim::Notification, :count).by(-invalid_entries.size)

          expect(Decidim::Notification.where(id: invalid_entries).length).to eq(0)
        end
      end
    end
  end
end
