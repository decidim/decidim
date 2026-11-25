# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Pages
    describe CopyPage do
      describe "call" do
        let(:component) { create(:component, manifest_name: "pages") }
        let!(:page) { create(:page, component:) }
        let(:new_component) { create(:component, manifest_name: "pages") }
        let(:context) { { new_component:, old_component: component } }
        let(:command) { described_class.new(context) }

        describe "when the page is not duplicated" do
          before do
            allow(Page).to receive(:create!).and_raise(ActiveRecord::RecordInvalid)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "does not duplicate the page" do
            expect do
              command.call
            end.not_to change(Page, :count)
          end
        end

        describe "when the page is duplicated" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "duplicates the page and its values" do
            expect(Page).to receive(:create!).with(component: new_component, body: page.body).and_call_original

            expect do
              command.call
            end.to change(Page, :count).by(1)
          end

          context "when the page has attachments" do
            before do
              # We do not optimize the eager loading here, as these associations are loaded by
              # .with_attached_file and .includes(:attachment_collection) and used internally
              # by ActiveStorage callbacks or the machine_translation callback, which Bullet does not track.
              Bullet.add_safelist type: :unused_eager_loading, class_name: "Decidim::Attachment", association: :file_attachment
              Bullet.add_safelist type: :unused_eager_loading, class_name: "ActiveStorage::Attachment", association: :blob
              Bullet.add_safelist type: :unused_eager_loading, class_name: "ActiveStorage::Blob", association: :variant_records
              Bullet.add_safelist type: :unused_eager_loading, class_name: "ActiveStorage::Blob", association: :preview_image_attachment
              Bullet.add_safelist type: :unused_eager_loading, class_name: "ActiveStorage::Attachment", association: :record
              Bullet.add_safelist type: :unused_eager_loading, class_name: "Decidim::Attachment", association: :attachment_collection
            end

            let!(:document) { create(:attachment, :with_pdf, attached_to: page) }
            let!(:photo) { create(:attachment, :with_image, attached_to: page) }

            it "copies attachments to the new page" do
              expect do
                command.call
              end.to change(Decidim::Attachment, :count).by(2)

              new_page = Page.last
              expect(new_page.attachments.count).to eq(2)
              expect(new_page.documents.count).to eq(1)
              expect(new_page.photos.count).to eq(1)
            end
          end
        end
      end
    end
  end
end
