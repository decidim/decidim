# frozen_string_literal: true

require "spec_helper"

shared_examples_for "questionnaire admin controller permissions" do
  describe "GET #edit" do
    let(:action) { :edit }

    it "enforces permission to update the questionnaire" do
      expect(controller).to receive(:enforce_permission_to).with(:update, permission_subject, questionnaire:)
      get action
    end
  end

  describe "PATCH #update" do
    let(:action) { :update }

    it "enforces permission to update the questionnaire" do
      expect(controller).to receive(:enforce_permission_to).with(:update, permission_subject, questionnaire:)
      patch action, params: { questionnaire: {} }
    end
  end

  describe "GET #edit_questions" do
    let(:action) { :edit_questions }

    it "enforces permission to update the questionnaire" do
      expect(controller).to receive(:enforce_permission_to).with(:update, permission_subject, questionnaire:)
      get action
    end
  end

  describe "PATCH #update_questions" do
    let(:action) { :update_questions }

    it "enforces permission to update the questionnaire" do
      expect(controller).to receive(:enforce_permission_to).with(:update, permission_subject, questionnaire:)
      patch action, params: { questions: {} }
    end
  end
end
