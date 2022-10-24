# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe CreateEditorImage do
    subject { described_class.new(form) }

    let(:form) do
      EditorImageForm.from_params(attributes).with_context(context)
    end
    let(:attributes) do
      {
        "editor_image" => {
          organization:,
          author_id: user_id,
          file:
        }
      }
    end
    let(:context) do
      {
        current_organization: organization,
        current_user: user
      }
    end
    let(:user) { create(:user, :admin, :confirmed) }
    let(:organization) { user.organization }
    let(:user_id) { user.id }
    let(:file) { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }

    context "when the form is not valid" do
      let(:user_id) { nil }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end

      it "doesn't create an editor image" do
        expect { subject.call }.not_to(change(Decidim::EditorImage, :count))
      end
    end

    context "when the form is valid" do
      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "creates an editor image" do
        expect { subject.call }.to change(Decidim::EditorImage, :count).by(1)
      end
    end
  end
end
