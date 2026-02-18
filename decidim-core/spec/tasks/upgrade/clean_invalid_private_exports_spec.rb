# frozen_string_literal: true

require "spec_helper"

describe "rake decidim:upgrade:clean:invalid_private_exports", type: :task do
  context "when executing task" do
    it "does not throw exceptions keys" do
      expect do
        Rake::Task[:"decidim:upgrade:clean:invalid_private_exports"].invoke
      end.not_to raise_exception
    end
  end

  context "when there are no errors" do
    let!(:exports) { create_list(:private_export, 5) }

    it "avoid removing entries" do
      expect { task.execute }.not_to change(Decidim::PrivateExport, :count)
    end
  end

  context "when there are errored entries" do
    let!(:exports) { create_list(:private_export, 5) }
    let!(:invalid_entry) { create(:private_export, export_type: "survey_user_responses_88ca03fab3b71024a7d97639bc10d62b771d69ae2c89d748055762e6b41d3e4d") }
    let!(:some_valid_entry) { create(:private_export, export_type: "survey_user_responses_88") }

    it "removes the entries" do
      expect { task.execute }.to change(Decidim::PrivateExport, :count).by(-1)
      expect { some_valid_entry.reload }.not_to raise_error
    end
  end
end
