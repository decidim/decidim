# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe NotificationsDigestMailer do
    let(:organization) { create(:organization) }
    let(:user) { create(:user, name: "Sarah Connor", organization:) }
    let(:notification_ids) { [notification.id] }
    let(:notification) { create(:notification, user:, resource:) }
    let(:component) { create(:component, :published, manifest_name: "dummy", organization:) }
    let(:resource) { create(:dummy_resource, :published, title: { en: %(Testing <a href="/resource">resource</a>) }, component:) }

    describe "digest_mail" do
      subject { described_class.digest_mail(user, notification_ids) }

      it "includes the link to the resource" do
        expect(subject.body).to include(
          %(<a href="#{::Decidim::ResourceLocatorPresenter.new(resource).url}">Testing resource</a>)
        )
      end

      context "when the notification is a comment" do
        let(:comment) { create(:comment, body: "This is a comment") }
        let(:event_name) { "decidim.events.comments.comment_created" }
        let(:event_class) { "Decidim::Comments::CommentCreatedEvent" }
        let(:extra) { { "comment_id" => comment.id, "received_as" => "follower" } }
        let(:notification) { create(:notification, user:, resource:, event_name:, event_class:, extra:) }

        it "includes the comment body" do
          expect(subject.body).to include("This is a comment")
        end
      end

      context "resource of notification is not visible" do
        context "when is moderated" do
          let(:moderation) { create(:moderation, reportable: resource, participatory_space: component.participatory_space, report_count: 1, hidden_at: Time.current) }
          let!(:report) { create(:report, moderation:, user:) }

          it "hides the notification" do
            expect(subject.body).not_to include(
                                          %(<a href="#{::Decidim::ResourceLocatorPresenter.new(resource).url}">Testing resource</a>)
                                        )
          end
        end

        context "when is deleted" do
          it "hides the notification" do
            resource.update(deleted_at: Time.current)
            expect(subject.body).not_to include(
                                          %(<a href="#{::Decidim::ResourceLocatorPresenter.new(resource).url}">Testing resource</a>)
                                        )
          end
        end

        context "when the component is not visible" do
          it "hides the notification" do
            component.update(published_at: nil)
            expect(subject.body).not_to include(
                                          %(<a href="#{::Decidim::ResourceLocatorPresenter.new(resource).url}">Testing resource</a>)
                                        )
          end
        end

        context "when the space is not published" do
          it "hides the notification" do
            component.participatory_space.update(published_at: nil)
            expect(subject.body).not_to include(
                                          %(<a href="#{::Decidim::ResourceLocatorPresenter.new(resource).url}">Testing resource</a>)
                                        )
          end
        end

        context "when the space is private" do
          it "hides the notification" do
            component.participatory_space.update(private_space: true)
            expect(subject.body).not_to include(
                                          %(<a href="#{::Decidim::ResourceLocatorPresenter.new(resource).url}">Testing resource</a>)
                                        )
          end
        end
      end

      context "when the space is private and user has access" do
        let!(:participatory_space) { create(:participatory_process, :private, organization: ) }
        let(:component) { create(:component, :published, manifest_name: "dummy", participatory_space:) }
        let!(:participatory_space_private_user) { create(:participatory_space_private_user, privatable_to: participatory_space, user: user) }

        it "displays the notification" do
          expect(subject.body).to include(
                                        %(<a href="#{::Decidim::ResourceLocatorPresenter.new(resource).url}">Testing resource</a>)
                                      )
        end
      end
      
      context "when the space is transparent and user has access" do
        let!(:participatory_space) { create(:assembly, :transparent, :private, organization: ) }
        let(:component) { create(:component, :published, manifest_name: "dummy", participatory_space:) }
        let!(:participatory_space_private_user) { create(:participatory_space_private_user, privatable_to: participatory_space, user: user) }

        it "displays the notification" do
          expect(subject.body).to include(
                                        %(<a href="#{::Decidim::ResourceLocatorPresenter.new(resource).url}">Testing resource</a>)
                                      )
        end
      end


      context "when the notification does not send emails" do
        let(:notification) { create(:notification, user:, resource:, event_class: "Decidim::Dev::DummyNotificationOnlyResourceEvent") }

        it "does not include the notification" do
          expect(subject.body).not_to include("Testing resource")
        end
      end
    end
  end
end
