# frozen_string_literal: true

require "spec_helper"

describe "rake decidim:upgrade:clean:action_logs", type: :task do
  context "when executing task" do
    it "does not throw exceptions keys" do
      expect { task.execute }.not_to raise_exception
    end

    context "when there are no errors" do
      let!(:action_logs) { create_list(:action_log, 8, created_at: 2.days.ago) }

      it "avoid removing entries" do
        expect { task.execute }.not_to change(Decidim::ActionLog, :count)
      end
    end

    context "when there are errors" do
      let!(:action_logs) { create_list(:action_log, 8, created_at: 2.days.ago) }
      let!(:invalid_entries) { action_logs.collect(&:id).sample(4) }

      context "when errors in Component" do
        it "removes entries" do
          Decidim::ActionLog.where(id: invalid_entries).update_all(resource_type: "Decidim::Component", resource_id: Time.now.to_i) # rubocop:disable Rails/SkipsModelValidations

          expect(Decidim::ActionLog.count).to eq(8)
          expect(Decidim::ActionLog.where(resource_type: "Decidim::Component").count).to eq(4)

          expect { task.execute }.to change(Decidim::ActionLog, :count).by(-invalid_entries.size)

          expect(Decidim::ActionLog.where(id: invalid_entries).length).to eq(0)
        end
      end

      context "when missing manifests" do
        context "when missing resource types" do
          it "removes entries" do
            Decidim::ActionLog.where(id: invalid_entries).update_all(resource_type: "Decidim::Dev::MissingResource") # rubocop:disable Rails/SkipsModelValidations

            expect(Decidim::ActionLog.count).to eq(8)
            expect(Decidim::ActionLog.where(resource_type: "Decidim::Dev::MissingResource").count).to eq(4)

            expect { task.execute }.to change(Decidim::ActionLog, :count).by(-invalid_entries.size)

            expect(Decidim::ActionLog.where(id: invalid_entries).length).to eq(0)
          end
        end

        context "when missing Space type types" do
          it "removes entries" do
            Decidim::ActionLog.where(id: invalid_entries).update_all(participatory_space_type: "Decidim::Dev::MissingSpace") # rubocop:disable Rails/SkipsModelValidations

            expect(Decidim::ActionLog.count).to eq(8)
            expect(Decidim::ActionLog.where(participatory_space_type: "Decidim::Dev::MissingSpace").count).to eq(4)

            expect { task.execute }.to change(Decidim::ActionLog, :count).by(-invalid_entries.size)

            expect(Decidim::ActionLog.where(id: invalid_entries).length).to eq(0)
          end
        end
      end
    end
  end
end
