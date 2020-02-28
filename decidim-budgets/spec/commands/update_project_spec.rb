# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets
  describe Admin::UpdateProject do
    subject { described_class.new(form, project) }

    let(:project) { create :project }
    let(:organization) { project.component.organization }
    let(:scope) { create :scope, organization: organization }
    let(:category) { create :category, participatory_space: project.component.participatory_space }
    let(:participatory_process) { project.component.participatory_space }
    let(:current_user) { create :user, :admin, :confirmed, organization: organization }
    let(:uploaded_images) { [] }
    let(:current_images) { [] }
    let(:proposal_component) do
      create(:component, manifest_name: :proposals, participatory_space: participatory_process)
    end
    let(:proposals) do
      create_list(
        :proposal,
        3,
        component: proposal_component
      )
    end
    let(:form) do
      double(
        invalid?: invalid,
        current_user: current_user,
        title: { en: "title" },
        description: { en: "description" },
        budget: 10_000_000,
        proposal_ids: proposals.map(&:id),
        scope: scope,
        category: category,
        photos: current_images,
        add_photos: uploaded_images
      )
    end
    let(:invalid) { false }

    context "when the form is not valid" do
      let(:invalid) { true }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when everything is ok" do
      it "updates the project" do
        subject.call
        expect(translated(project.title)).to eq "title"
      end

      it "sets the scope" do
        subject.call
        expect(project.scope).to eq scope
      end

      it "sets the category" do
        subject.call
        expect(project.category).to eq category
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:update!)
          .with(project, current_user, hash_including(:scope, :category, :title, :description, :budget))
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end

      it "links proposals" do
        subject.call
        linked_proposals = project.linked_resources(:proposals, "included_proposals")
        expect(linked_proposals).to match_array(proposals)
      end

      context "when managing images", processing_uploads_for: Decidim::AttachmentUploader do
        let(:uploaded_images) do
          [
            Decidim::Dev.test_file("city.jpeg", "image/jpeg"),
            Decidim::Dev.test_file("city2.jpeg", "image/jpeg")
          ]
        end

        it "creates a gallery for the project" do
          expect { subject.call }.to change(Decidim::Attachment, :count).by(2)
          project = Decidim::Budgets::Project.last
          expect(project.photos.count).to eq(2)
          last_attachment = Decidim::Attachment.last
          expect(last_attachment.attached_to).to eq(project)
        end

        context "when gallery is left blank" do
          let(:uploaded_images) { [] }

          it "broadcasts ok" do
            expect { subject.call }.to broadcast(:ok)
          end
        end

        context "when images are removed" do
          let!(:project) { create :project }
          let!(:image1) { create(:attachment, :with_image, attached_to: project) }
          let!(:image2) { create(:attachment, :with_image, attached_to: project) }
          let(:uploaded_images) { [] }
          let(:current_images) { [image1.id.to_s] }

          it "to decrease the number of photos in the gallery" do
            expect(project.attachments.count).to eq(2)
            expect(project.photos.count).to eq(2)
            expect { subject.call }.to change(Decidim::Attachment, :count).by(-1)
            expect(project.attachments.count).to eq(1)
            expect(project.photos.count).to eq(1)
          end
        end
      end
    end
  end
end
