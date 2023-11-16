# frozen_string_literal: true

require "decidim/components/namer"
require "decidim/faker/localized"

module Decidim
  module Proposals
    class Seeds
      attr_reader :participatory_space

      def initialize(participatory_space:)
        @participatory_space = participatory_space
      end

      def call
        component = create_component!

        5.times do |n|
          proposal = create_proposal!(component:)

          emendation = create_emendation!(proposal:) if proposal.state.nil?

          (n % 3).times do |_m|
            create_proposal_votes!(proposal:, emendation:)
          end

          (n % 3).times do
            create_proposal_notes!(proposal:)
          end

          Decidim::Comments::Seed.comments_for(proposal)

          create_collaborative_draft!(component:)
        end

        update_traceability!(component:)
      end

      def organization
        @organization ||= participatory_space.organization
      end

      def admin_user = Decidim::User.find_by(organization:, email: "admin@example.org")

      def create_component!
        step_settings = if participatory_space.allows_steps?
                          { participatory_space.active_step.id => { votes_enabled: true, votes_blocked: false, creation_enabled: true } }
                        else
                          {}
                        end

        params = {
          name: Decidim::Components::Namer.new(participatory_space.organization.available_locales, :proposals).i18n_name,
          manifest_name: :proposals,
          published_at: Time.current,
          participatory_space:,
          settings: {
            vote_limit: 0,
            collaborative_drafts_enabled: true
          },
          step_settings:
        }

        Decidim.traceability.perform_action!(
          "publish",
          Decidim::Component,
          admin_user,
          visibility: "all"
        ) do
          Decidim::Component.create!(params)
        end
      end

      def create_proposal!(component:)
        n = rand(5)
        state, answer, state_published_at = if n > 3
                                              ["accepted", Decidim::Faker::Localized.sentence(word_count: 10), Time.current]
                                            elsif n > 2
                                              ["rejected", nil, Time.current]
                                            elsif n > 1
                                              ["evaluating", nil, Time.current]
                                            elsif n.positive?
                                              ["accepted", Decidim::Faker::Localized.sentence(word_count: 10), nil]
                                            else
                                              ["not_answered", nil, nil]
                                            end

        params = {
          component:,
          category: participatory_space.categories.sample,
          scope: random_scope,
          title: { en: ::Faker::Lorem.sentence(word_count: 2) },
          body: { en: ::Faker::Lorem.paragraphs(number: 2).join("\n") },
          state:,
          answer:,
          answered_at: state.present? ? Time.current : nil,
          state_published_at:,
          published_at: Time.current
        }

        proposal = Decidim.traceability.perform_action!(
          "publish",
          Decidim::Proposals::Proposal,
          admin_user,
          visibility: "all"
        ) do
          proposal = Decidim::Proposals::Proposal.new(params)
          meeting_component = participatory_space.components.find_by(manifest_name: "meetings")

          coauthor = case n
                     when 0
                       Decidim::User.where(organization:).sample
                     when 1
                       Decidim::UserGroup.where(organization:).sample
                     when 2
                       Decidim::Meetings::Meeting.where(component: meeting_component).sample
                     else
                       organization
                     end
          proposal.add_coauthor(coauthor)
          proposal.save!
          proposal
        end
      end

      def create_emendation!(proposal:)
        n = rand(5)
        email = "amendment-author-#{participatory_space.underscored_name}-#{participatory_space.id}-#{n}-amend#{n}@example.org"
        name = "#{::Faker::Name.name} #{participatory_space.id} #{n} amend#{n}"

        author = Decidim::User.find_or_initialize_by(email:)
        author.update!(
          password: "decidim123456789",
          name:,
          nickname: ::Faker::Twitter.unique.screen_name,
          organization:,
          tos_agreement: "1",
          confirmed_at: Time.current
        )

        group = Decidim::UserGroup.create!(
          name: ::Faker::Name.name,
          nickname: ::Faker::Twitter.unique.screen_name,
          email: ::Faker::Internet.email,
          extended_data: {
            document_number: ::Faker::Code.isbn,
            phone: ::Faker::PhoneNumber.phone_number,
            verified_at: Time.current
          },
          organization:,
          confirmed_at: Time.current
        )

        Decidim::UserGroupMembership.create!(
          user: author,
          role: "creator",
          user_group: group
        )

        params = {
          component: proposal.component,
          category: participatory_space.categories.sample,
          scope: random_scope,
          title: { en: "#{proposal.title["en"]} #{::Faker::Lorem.sentence(word_count: 1)}" },
          body: { en: "#{proposal.body["en"]} #{::Faker::Lorem.sentence(word_count: 3)}" },
          state: "evaluating",
          answer: nil,
          answered_at: Time.current,
          published_at: Time.current
        }

        emendation = Decidim.traceability.perform_action!(
          "create",
          Decidim::Proposals::Proposal,
          author,
          visibility: "public-only"
        ) do
          emendation = Decidim::Proposals::Proposal.new(params)
          emendation.add_coauthor(author, user_group: author.user_groups.first)
          emendation.save!
          emendation
        end

        Decidim::Amendment.create!(
          amender: author,
          amendable: proposal,
          emendation:,
          state: "evaluating"
        )

        emendation
      end

      def create_proposal_votes!(proposal:, emendation: nil)
        n = rand(5)
        m = rand(5)
        email = "vote-author-#{participatory_space.underscored_name}-#{participatory_space.id}-#{n}-#{m}@example.org"
        name = "#{::Faker::Name.name} #{participatory_space.id} #{n} #{m}"

        author = Decidim::User.find_or_initialize_by(email:)
        author.update!(
          password: "decidim123456789",
          name:,
          nickname: ::Faker::Twitter.unique.screen_name,
          organization:,
          tos_agreement: "1",
          confirmed_at: Time.current,
          personal_url: ::Faker::Internet.url,
          about: ::Faker::Lorem.paragraph(sentence_count: 2)
        )

        Decidim::Proposals::ProposalVote.create!(proposal:, author:) unless proposal.published_state? && proposal.rejected?
        Decidim::Proposals::ProposalVote.create!(proposal: emendation, author:) if emendation
      end

      def create_proposal_notes!(proposal:)
        author_admin = Decidim::User.where(organization:, admin: true).all.sample

        Decidim::Proposals::ProposalNote.create!(
          proposal:,
          author: author_admin,
          body: ::Faker::Lorem.paragraphs(number: 2).join("\n")
        )
      end

      def create_collaborative_draft!(component:)
        n = rand(5)
        state = if n > 3
                  "published"
                elsif n > 2
                  "withdrawn"
                else
                  "open"
                end
        author = Decidim::User.where(organization:).all.sample

        draft = Decidim.traceability.perform_action!("create", Decidim::Proposals::CollaborativeDraft, author) do
          draft = Decidim::Proposals::CollaborativeDraft.new(
            component:,
            category: participatory_space.categories.sample,
            scope: random_scope,
            title: ::Faker::Lorem.sentence(word_count: 2),
            body: ::Faker::Lorem.paragraphs(number: 2).join("\n"),
            state:,
            published_at: Time.current
          )
          draft.coauthorships.build(author: participatory_space.organization)
          draft.save!
          draft
        end

        case n
        when 2
          authors = Decidim::User.where(organization:).all.sample(5)
          authors.each do |local_author|
            Decidim::Coauthorship.create(coauthorable: draft, author: local_author)
          end
        when 3
          author2 = Decidim::User.where(organization:).all.sample
          Decidim::Coauthorship.create(coauthorable: draft, author: author2)
        end

        Decidim::Comments::Seed.comments_for(draft)
      end

      def update_traceability!(component:)
        Decidim.traceability.update!(
          Decidim::Proposals::CollaborativeDraft.all.sample,
          Decidim::User.where(organization:).all.sample,
          component:,
          category: participatory_space.categories.sample,
          scope: random_scope,
          title: ::Faker::Lorem.sentence(word_count: 2),
          body: ::Faker::Lorem.paragraphs(number: 2).join("\n")
        )
      end

      def random_scope
        if participatory_space.scope
          scopes = participatory_space.scope.descendants
          global = participatory_space.scope
        else
          scopes = participatory_space.organization.scopes
          global = nil
        end

        ::Faker::Boolean.boolean(true_ratio: 0.5) ? global : scopes.sample
      end
    end
  end
end
