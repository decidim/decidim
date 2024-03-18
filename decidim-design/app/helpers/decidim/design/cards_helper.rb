# frozen_string_literal: true

module Decidim
  module Design
    module CardsHelper
      include ::Decidim::CardHelper

      class DummyClass < ApplicationRecord
        self.table_name = Decidim::Pages::Page.table_name

        attr_accessor :organization, :title, :description

        def resource_locator
          Class.new do
            def path(*_args)
              "#"
            end
          end.new
        end
      end

      def cards_sections
        [
          {
            id: "types",
            title: t("decidim.design.helpers.types"),
            contents: [
              {
                values: section_subtitle(title: t("decidim.design.helpers.card_l"), label: t("decidim.design.helpers.list"))
              },
              {
                type: :partial,
                template: "decidim/design/components/cards/static-card-l"
              },
              {
                type: :partial,
                template: "decidim/design/components/cards/static-card-l"
              },
              {
                values: section_subtitle(title: t("decidim.design.helpers.card_g"), label: t("decidim.design.helpers.grid"))
              },
              {
                type: :partial,
                layout: "decidim/design/shared/card_grid",
                template: ["decidim/design/components/cards/static-card-g", "decidim/design/components/cards/static-card-g"]
              },
              {
                values: section_subtitle(title: t("decidim.design.helpers.card_s"), label: t("decidim.design.helpers.search"))
              },
              {
                type: :partial,
                template: "decidim/design/components/cards/static-card-s"
              },
              {
                type: :partial,
                template: "decidim/design/components/cards/static-card-s"
              }
            ]
          },
          {
            id: "variations",
            title: t("decidim.design.helpers.variations"),
            contents: [
              {
                type: :text,
                values: [t("decidim.design.helpers.variations_cards_description")]
              },
              {
                values: section_subtitle(title: t("decidim.design.helpers.metadata_items"))
              },
              {
                type: :partial,
                layout: "decidim/design/shared/card_grid",
                template: ["decidim/design/components/cards/static-card-g-metadata", "decidim/design/components/cards/static-card-g-metadata-2"]
              },
              {
                type: :text,
                values: [t("decidim.design.helpers.metadata_text")]
              },
              {
                values: section_subtitle(title: t("decidim.design.helpers.highlight"))
              },
              {
                type: :partial,
                template: "decidim/design/components/cards/static-card-g-highlight"
              },
              {
                type: :text,
                values: [t("decidim.design.helpers.highlight_description")]
              },
              {
                values: section_subtitle(title: t("decidim.design.helpers.image_and_description"))
              },
              {
                type: :partial,
                template: "decidim/design/components/cards/static-card-l-image"
              },
              {
                type: :text,
                values: [t("decidim.design.helpers.blog_cards_html")]
              },
              {
                values: section_subtitle(title: t("decidim.design.helpers.description"))
              },
              {
                type: :partial,
                template: "decidim/design/components/cards/static-card-l-description"
              },
              {
                type: :text,
                values: [t("decidim.design.helpers.debates_cards_html")]
              },
              {
                values: section_subtitle(title: t("decidim.design.helpers.debates_cards_text"))
              },
              {
                type: :partial,
                template: "decidim/design/components/cards/static-card-l-meetings"
              },
              {
                type: :text,
                values: [t("decidim.design.helpers.meetings_html")]
              },
              {
                values: section_subtitle(title: t("decidim.design.helpers.block_text"))
              },
              {
                type: :partial,
                template: "decidim/design/components/cards/static-card-l-extra-data"
              },
              {
                type: :text,
                values: [t("decidim.design.helpers.accountability_cards_html")]
              },
              {
                type: :partial,
                template: "decidim/design/components/cards/static-card-l-extra-data-2"
              },
              {
                type: :text,
                values: [t("decidim.design.helpers.budget_card_html")]
              }
            ]
          },
          {
            id: "source_code",
            title: t("decidim.design.helpers.source_code"),
            contents: source_contents
          }
        ]
      end

      def source_contents
        dummy_resource = DummyClass.new(
          id: 1000,
          organization: current_organization,
          title: t("decidim.design.helpers.dummy_title"),
          description: t("decidim.design.helpers.dummy_description")
        )

        contents = [
          { values: section_subtitle(title: t("decidim.design.helpers.generic_cards")) },
          cell_table_item(t("decidim.design.helpers.card_g"), { cell: "decidim/card_l", args: [dummy_resource], call_string: 'cell("decidim/card_l", _RESOURCE_)' }),
          cell_table_item(t("decidim.design.helpers.card_l"), { cell: "decidim/card_l", args: [dummy_resource], call_string: 'cell("decidim/card_g", _RESOURCE_)' }),
          cell_table_item(t("decidim.design.helpers.card_s"), { cell: "decidim/card_l", args: [dummy_resource], call_string: 'cell("decidim/card_s", _RESOURCE_)' })
        ]

        contents += accountability_items
        contents += blogs_items
        contents += budgets_items
        contents += debates_items
        contents += meetings_items
        contents += proposals_items
        contents += sortitions_items
        contents += assemblies_items
        contents += conferences_items
        contents += initiatives_items
        contents += participatory_processes_items

        contents
      end

      private

      def accountability_items
        return [] unless Decidim.module_installed?(:accountability) && (resource = Decidim::Accountability::Result.last).present?

        [
          { values: section_subtitle(title: t("decidim.design.helpers.accountability")) },
          cell_table_item(
            t("decidim.design.helpers.result_l"),
            {
              cell: "decidim/accountability/result_l",
              args: [resource],
              call_string: [
                "card_for(_RESOURCE_)",
                "card_for(_RESOURCE_, size: :l)",
                'cell("decidim/accountability/result", _RESOURCE_)',
                'cell("decidim/accountability/result", _RESOURCE_, size: :l)',
                'cell("decidim/accountability/result_l", _RESOURCE_)'
              ]
            }
          )
        ]
      end

      def blogs_items
        return [] unless Decidim.module_installed?(:blogs) && (resource = Decidim::Blogs::Post.last).present?

        [
          { values: section_subtitle(title: t("decidim.design.helpers.blogs")) },
          cell_table_item(
            t("decidim.design.helpers.post_l"),
            {
              cell: "decidim/blogs/post_l",
              args: [resource],
              call_string: [
                "card_for(_RESOURCE_)",
                "card_for(_RESOURCE_, size: :l)",
                'cell("decidim/blogs/post", _RESOURCE_)',
                'cell("decidim/blogs/post", _RESOURCE_, size: :l)',
                'cell("decidim/blogs/post_l", _RESOURCE_)'
              ]
            }
          ),
          cell_table_item(
            t("decidim.design.helpers.post_g"),
            {
              cell: "decidim/blogs/post_g",
              args: [resource],
              call_string: [
                "card_for(_RESOURCE_, size: :g)",
                'cell("decidim/blogs/post", _RESOURCE_, size: :g)',
                'cell("decidim/blogs/post_g", _RESOURCE_)'
              ]
            }
          ),
          cell_table_item(
            t("decidim.design.helpers.post_s"),
            {
              cell: "decidim/blogs/post_s",
              args: [resource],
              call_string: [
                "card_for(_RESOURCE_, size: :s)",
                'cell("decidim/blogs/post", _RESOURCE_, size: :s)',
                'cell("decidim/blogs/post_s", _RESOURCE_)'
              ]
            }
          )
        ]
      end

      def budgets_items
        return [] unless Decidim.module_installed?(:budgets) && (resource = Decidim::Budgets::Project.last).present?

        [
          { values: section_subtitle(title: t("decidim.design.helpers.budgets")) },
          cell_table_item(
            t("decidim.design.helpers.project_l"),
            {
              cell: "decidim/budgets/project_l",
              args: [resource],
              call_string: [
                "card_for(_RESOURCE_)",
                "card_for(_RESOURCE_), size: :l",
                'cell("decidim/budgets/project", _RESOURCE_)',
                'cell("decidim/budgets/project", _RESOURCE_, size: :l)',
                'cell("decidim/budgets/project_l", _RESOURCE_)'
              ]
            }
          ),
          cell_table_item(
            t("decidim.design.helpers.project_s"),
            {
              cell: "decidim/budgets/project_s",
              args: [resource],
              call_string: [
                "card_for(_RESOURCE_), size: :s",
                'cell("decidim/budgets/project", _RESOURCE_, size: :s)',
                'cell("decidim/budgets/project_s", _RESOURCE_)'
              ]
            }
          )
        ]
      end

      def debates_items
        return [] unless Decidim.module_installed?(:debates) && (resource = Decidim::Debates::Debate.last).present?

        [
          { values: section_subtitle(title: t("decidim.design.helpers.debates")) },
          cell_table_item(
            t("decidim.design.helpers.debate_l"),
            {
              cell: "decidim/debates/debate_l",
              args: [resource],
              call_string: [
                "card_for(_RESOURCE_)",
                "card_for(_RESOURCE_), size: :l",
                'cell("decidim/debates/debate", _RESOURCE_)',
                'cell("decidim/debates/debate", _RESOURCE_, size: :l)',
                'cell("decidim/debates/debate_l", _RESOURCE_)'
              ]
            }
          ),
          cell_table_item(
            t("decidim.design.helpers.debate_s"),
            {
              cell: "decidim/debates/debate_s",
              args: [resource],
              call_string: [
                "card_for(_RESOURCE_), size: :s",
                'cell("decidim/debates/debate", _RESOURCE_, size: :s)',
                'cell("decidim/debates/debate_s", _RESOURCE_)'
              ]
            }
          )
        ]
      end

      def meetings_items
        return [] unless Decidim.module_installed?(:meetings) && (resource = Decidim::Meetings::Meeting.last).present?

        [
          { values: section_subtitle(title: t("decidim.design.helpers.meetings")) },
          cell_table_item(
            t("decidim.design.helpers.meeting_l"),
            {
              cell: "decidim/meetings/meeting_l",
              args: [resource],
              call_string: [
                "card_for(_RESOURCE_)",
                "card_for(_RESOURCE_, size: :l)",
                'cell("decidim/meetings/meeting", _RESOURCE_)',
                'cell("decidim/meetings/meeting", _RESOURCE_, size: :l)',
                'cell("decidim/meetings/meeting_l", _RESOURCE_)'
              ]
            }
          ),
          cell_table_item(
            t("decidim.design.helpers.meeting_s"),
            {
              cell: "decidim/meetings/meeting_s",
              args: [resource],
              call_string: [
                "card_for(_RESOURCE_, size: :s)",
                'cell("decidim/meetings/meeting", _RESOURCE_, size: :s)',
                'cell("decidim/meetings/meeting_s", _RESOURCE_)'
              ]
            }
          )
        ]
      end

      def proposals_items
        items = []
        return items unless Decidim.module_installed?(:proposals)

        proposal_resource = Decidim::Proposals::Proposal.last
        collaborative_draft_resource = Decidim::Proposals::CollaborativeDraft.last

        items << { values: section_subtitle(title: t("decidim.design.helpers.proposals")) } if [proposal_resource, collaborative_draft_resource].any?(&:present?)

        if (resource = proposal_resource).present?
          items += [
            cell_table_item(
              t("decidim.design.helpers.proposal_l"),
              {
                cell: "decidim/proposals/proposal_l",
                args: [resource],
                call_string: [
                  "card_for(_RESOURCE_)",
                  "card_for(_RESOURCE_, size: :l)",
                  'cell("decidim/proposals/proposal", _RESOURCE_)',
                  'cell("decidim/proposals/proposal", _RESOURCE_, size: :l)',
                  'cell("decidim/proposals/proposal_l", _RESOURCE_)'
                ]
              }
            ),
            cell_table_item(
              t("decidim.design.helpers.proposal_s"),
              {
                cell: "decidim/proposals/proposal_s",
                args: [resource],
                call_string: [
                  "card_for(_RESOURCE_, size: :s)",
                  'cell("decidim/proposals/proposal", _RESOURCE_, size: :s)',
                  'cell("decidim/proposals/proposal_s", _RESOURCE_)'
                ]
              }
            )
          ]
        end

        if (resource = collaborative_draft_resource).present?
          items += [
            cell_table_item(
              t("decidim.design.helpers.collaborative_draft_l"),
              {
                cell: "decidim/proposals/collaborative_draft_l",
                args: [resource],
                call_string: [
                  "card_for(_RESOURCE_)",
                  'cell("decidim/proposals/collaborative_draft", _RESOURCE_)',
                  'cell("decidim/proposals/collaborative_draft_l", _RESOURCE_)'
                ]
              }
            )
          ]
        end

        items
      end

      def sortitions_items
        return [] unless Decidim.module_installed?(:sortitions) && (resource = Decidim::Sortitions::Sortition.last).present?

        [
          { values: section_subtitle(title: t("decidim.design.helpers.sortitions")) },
          cell_table_item(
            t("decidim.design.helpers.sortition_l"),
            {
              cell: "decidim/sortitions/sortition_l",
              args: [resource],
              call_string: [
                "card_for(_RESOURCE_)",
                'cell("decidim/sortitions/sortition", _RESOURCE_)',
                'cell("decidim/sortitions/sortition_l", _RESOURCE_)'
              ]
            }
          )
        ]
      end

      def assemblies_items
        return [] unless Decidim.module_installed?(:assemblies) && (resource = Decidim::Assembly.last).present?

        [
          { values: section_subtitle(title: t("decidim.design.helpers.assemblies")) },
          cell_table_item(
            t("decidim.design.helpers.assembly_g"),
            {
              cell: "decidim/assemblies/assembly_g",
              args: [resource],
              call_string: [
                "card_for(_RESOURCE_)",
                "card_for(_RESOURCE_, size: :g)",
                'cell("decidim/assemblies/assembly", _RESOURCE_)',
                'cell("decidim/assemblies/assembly", _RESOURCE_, size: :g)',
                'cell("decidim/assemblies/assembly_g", _RESOURCE_)'
              ]
            }
          ),
          cell_table_item(
            t("decidim.design.helpers.assembly_s"),
            {
              cell: "decidim/assemblies/assembly_s",
              args: [resource],
              call_string: [
                "card_for(_RESOURCE_, size: :s)",
                'cell("decidim/assemblies/assembly", _RESOURCE_, size: :s)',
                'cell("decidim/assemblies/assembly_s", _RESOURCE_)'
              ]
            }
          )
        ]
      end

      def conferences_items
        return [] unless Decidim.module_installed?(:conferences) && (resource = Decidim::Conference.last).present?

        [
          { values: section_subtitle(title: t("decidim.design.helpers.conferences")) },
          cell_table_item(
            t("decidim.design.helpers.conference_g"),
            {
              cell: "decidim/conferences/conference_g",
              args: [resource],
              call_string: [
                "card_for(_RESOURCE_)",
                "card_for(_RESOURCE_, size: :g)",
                'cell("decidim/conferences/conference", _RESOURCE_)',
                'cell("decidim/conferences/conference", _RESOURCE_, size: :g)',
                'cell("decidim/conferences/conference_g", _RESOURCE_)'
              ]
            }
          ),
          cell_table_item(
            t("decidim.design.helpers.conference_s"),
            {
              cell: "decidim/conferences/conference_s",
              args: [resource],
              call_string: [
                "card_for(_RESOURCE_, size: :s)",
                'cell("decidim/conferences/conference", _RESOURCE_, size: :s)',
                'cell("decidim/conferences/conference_s", _RESOURCE_)'
              ]
            }
          )
        ]
      end

      def initiatives_items
        return [] unless Decidim.module_installed?(:initiatives) && (resource = Decidim::Initiative.last).present?

        [
          { values: section_subtitle(title: t("decidim.design.helpers.initiatives")) },
          cell_table_item(
            t("decidim.design.helpers.initiative_g"),
            {
              cell: "decidim/initiatives/initiative_g",
              args: [resource],
              call_string: [
                "card_for(_RESOURCE_)",
                "card_for(_RESOURCE_, size: :g)",
                'cell("decidim/initiatives/initiative", _RESOURCE_)',
                'cell("decidim/initiatives/initiative", _RESOURCE_, size: :g)',
                'cell("decidim/initiatives/initiative_g", _RESOURCE_)'
              ]
            }
          ),
          cell_table_item(
            t("decidim.design.helpers.initiative_s"),
            {
              cell: "decidim/initiatives/initiative_s",
              args: [resource],
              call_string: [
                "card_for(_RESOURCE_, size: :s)",
                'cell("decidim/initiatives/initiative", _RESOURCE_, size: :s)',
                'cell("decidim/initiatives/initiative_s", _RESOURCE_)'
              ]
            }
          )
        ]
      end

      def participatory_processes_items
        items = []
        return items unless Decidim.module_installed?(:participatory_processes)

        process_resource = Decidim::ParticipatoryProcess.last
        process_group_resource = Decidim::ParticipatoryProcessGroup.last

        items << { values: section_subtitle(title: t("decidim.design.helpers.participatory_processes")) } if [process_resource, process_group_resource].any?(&:present?)

        if (resource = process_resource).present?
          items += [
            cell_table_item(
              t("decidim.design.helpers.participatory_process_g"),
              {
                cell: "decidim/participatory_processes/process_g",
                args: [resource],
                call_string: [
                  "card_for(_RESOURCE_)",
                  "card_for(_RESOURCE_, size: :g)",
                  'cell("decidim/participatory_processes/process", _RESOURCE_)',
                  'cell("decidim/participatory_processes/process", _RESOURCE_, size: :g)',
                  'cell("decidim/participatory_processes/process_g", _RESOURCE_)'
                ]
              }
            ),
            cell_table_item(
              t("decidim.design.helpers.participatory_process_s"),
              {
                cell: "decidim/participatory_processes/process_s",
                args: [resource],
                call_string: [
                  "card_for(_RESOURCE_, size: :s)",
                  'cell("decidim/participatory_processes/process", _RESOURCE_, size: :s)',
                  'cell("decidim/participatory_processes/process_s", _RESOURCE_)'
                ]
              }
            )
          ]
        end

        if (resource = process_group_resource).present?
          items += [
            cell_table_item(
              t("decidim.design.helpers.participatory_process_group_g"),
              {
                cell: "decidim/participatory_processes/process_group_g",
                args: [resource],
                call_string: [
                  "card_for(_RESOURCE_)",
                  "card_for(_RESOURCE_, size: :g)",
                  'cell("decidim/participatory_processes/process_group", _RESOURCE_)',
                  'cell("decidim/participatory_processes/process_group", _RESOURCE_, size: :g)',
                  'cell("decidim/participatory_processes/process_group_g", _RESOURCE_)'
                ]
              }
            ),
            cell_table_item(
              t("decidim.design.helpers.participatory_process_group_s"),
              {
                cell: "decidim/participatory_processes/process_group_s",
                args: [resource],
                call_string: [
                  "card_for(_RESOURCE_, size: :s)",
                  'cell("decidim/participatory_processes/process_group", _RESOURCE_, size: :s)',
                  'cell("decidim/participatory_processes/process_group_s", _RESOURCE_)'
                ]
              }
            )
          ]
        end

        items
      end

      def cell_table_item(heading, cell_snippet = {})
        {
          type: :cell_table,
          options: { headings: [heading] },
          values: [""],
          cell_snippet:
        }
      end

      def cards_table(*table_rows, **_opts)
        table_rows.map do |table_cell|
          [
            table_cell[:name],
            link_to(table_cell[:url].split("/").last, table_cell[:url], target: "_blank", class: "text-secondary underline", rel: "noopener"),
            if table_cell[:usage].to_s.start_with?("http")
              link_to(table_cell[:usage].split("/").last, table_cell[:usage], target: "_blank", class: "text-secondary underline", rel: "noopener")
            else
              table_cell[:usage]
            end
          ]
        end
      end
    end
  end
end
