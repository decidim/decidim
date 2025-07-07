# frozen_string_literal: true

require "spec_helper"

describe "rake decidim_surveys:upgrade:fix_survey_component_permissions", type: :task do
  let!(:legacy_component) { create(:surveys_component, permissions: { "answer" => { "authorization_handlers" => { "id_documents" => {} } } }) }
  let!(:old_component) { create(:surveys_component, permissions: { "respond" => { "authorization_handlers" => { "id_documents" => {} } } }) }
  let!(:new_component) { create(:surveys_component, permissions: { "response" => { "authorization_handlers" => { "id_documents" => {} } } }) }

  context "when executing task" do
    it "does not raise an error" do
      expect { task.execute }.not_to raise_error
    end

    it "changes the permissions of the oldest component permission" do
      expect(legacy_component.permissions).not_to have_key("response")
      expect(legacy_component.permissions).to have_key("answer")

      expect { task.execute }.to(change { legacy_component.reload.permissions })

      expect(legacy_component.permissions).to have_key("response")
      expect(legacy_component.permissions).not_to have_key("answer")
    end

    it "changes the permissions of the old component" do
      expect(old_component.permissions).not_to have_key("response")
      expect(old_component.permissions).to have_key("respond")

      expect { task.execute }.to(change { old_component.reload.permissions })

      expect(old_component.permissions).to have_key("response")
      expect(old_component.permissions).not_to have_key("respond")
    end

    it "ignores the permissions of the right task" do
      expect(new_component.permissions).to have_key("response")
      expect(new_component.permissions).not_to have_key("respond")

      expect { task.execute }.not_to(change { new_component.reload.permissions })

      expect(new_component.permissions).to have_key("response")
      expect(new_component.permissions).not_to have_key("respond")
    end
  end
end
