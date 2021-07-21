# frozen_string_literal: true

shared_examples_for "a translated meeting event" do
  describe "translated notifications" do
    let(:resource) do
      create :meeting,
             title: { "en": "A nice event", "machine_translations": { "ca": "Une belle event" } },
             description: { "en": "A nice event", "machine_translations": { "ca": "Une belle event" } }
    end

    context "when it is not machine machine translated" do
      before do
        organization = resource.organization
        organization.update enable_machine_translations: false
      end

      it "does not perform translation" do
        expect(subject.perform_translation?).to eq(false)
      end

      it "does not have a missing translation" do
        expect(subject.translation_missing?).to eq(false)
      end

      it "does have content available in multiple languages" do
        expect(subject.content_in_same_language?).to eq(false)
      end

      it "does return the original language" do
        expect(subject.safe_resource_text).to eq(resource.description["en"])
      end

      it "does not offer an alternate translation" do
        expect(subject.safe_resource_translated_text).to eq(resource.description["en"])
      end
    end

    context "when is machine machine translated" do
      let(:user) { create :user, organization: organization, locale: "ca" }

      before do
        organization = resource.organization
        organization.update enable_machine_translations: true
      end

      around do |example|
        I18n.with_locale(user.locale) { example.run }
      end

      context "when priority is original" do
        before do
          organization.update machine_translation_display_priority: "original"
        end

        it "does perform translation" do
          expect(subject.perform_translation?).to eq(true)
        end

        it "does not have a missing translation" do
          expect(subject.translation_missing?).to eq(false)
        end

        it "does have content available in multiple languages" do
          expect(subject.content_in_same_language?).to eq(false)
        end

        it "does return the original language" do
          expect(subject.safe_resource_text).to eq(resource.description["en"])
        end

        it "does not offer an alternate translation" do
          expect(subject.safe_resource_translated_text).to eq(resource.description["machine_translations"]["ca"])
        end

        context "when translation is not available" do
          let(:resource) do
            create :meeting,
                   title: { "en": "A nice event" },
                   description: { "en": "A nice event" }
          end

          it "does perform translation" do
            expect(subject.perform_translation?).to eq(true)
          end

          it "does have a missing translation" do
            expect(subject.translation_missing?).to eq(true)
          end

          it "does have content available in multiple languages" do
            expect(subject.content_in_same_language?).to eq(false)
          end

          it "does return the original language" do
            expect(subject.safe_resource_text).to eq(resource.description["en"])
          end

          it "does not offer an alternate translation" do
            expect(subject.safe_resource_translated_text).to eq(resource.description["en"])
          end
        end
      end

      context "when priority is translation" do
        before do
          organization.update machine_translation_display_priority: "translation"
        end

        it "does perform translation" do
          expect(subject.perform_translation?).to eq(true)
        end

        it "does not have a missing translation" do
          expect(subject.translation_missing?).to eq(false)
        end

        it "does have content available in multiple languages" do
          expect(subject.content_in_same_language?).to eq(false)
        end

        it "does return the original language" do
          expect(subject.safe_resource_text).to eq(resource.description["en"])
        end

        it "does not offer an alternate translation" do
          expect(subject.safe_resource_translated_text).to eq(resource.description["machine_translations"]["ca"])
        end

        context "when translation is not available" do
          let(:resource) do
            create :meeting,
                   title: { "en": "A nice event" },
                   description: { "en": "A nice event" }
          end

          it "does perform translation" do
            expect(subject.perform_translation?).to eq(true)
          end

          it "does have a missing translation" do
            expect(subject.translation_missing?).to eq(true)
          end

          it "does have content available in multiple languages" do
            expect(subject.content_in_same_language?).to eq(false)
          end

          it "does return the original language" do
            expect(subject.safe_resource_text).to eq(resource.description["en"])
          end

          it "does not offer an alternate translation" do
            expect(subject.safe_resource_translated_text).to eq(resource.description["en"])
          end
        end
      end
    end
  end
end
