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

      # rubocop:disable Layout/LineLength
      def cards_sections
        [
          {
            id: "types",
            contents: [
              {
                values: section_subtitle(title: "Card L", label: "list")
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
                values: section_subtitle(title: "Card G", label: "grid")
              },
              {
                type: :partial,
                layout: "decidim/design/shared/card_grid",
                template: ["decidim/design/components/cards/static-card-g", "decidim/design/components/cards/static-card-g"]
              },
              {
                values: section_subtitle(title: "Card S", label: "search")
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
            contents: [
              {
                type: :text,
                values: ["Each card will look like different regarding the properties of the resource displayed. You can override such behaviour in the specific cell."]
              },
              {
                values: section_subtitle(title: "Metadata items")
              },
              {
                type: :partial,
                layout: "decidim/design/shared/card_grid",
                template: ["decidim/design/components/cards/static-card-g-metadata", "decidim/design/components/cards/static-card-g-metadata-2"]
              },
              {
                type: :text,
                values: ["Each resource define its own metadata items"]
              },
              {
                values: section_subtitle(title: "Highlight")
              },
              {
                type: :partial,
                template: "decidim/design/components/cards/static-card-g-highlight"
              },
              {
                type: :text,
                values: ["Used by resources who allow to highlight"]
              },
              {
                values: section_subtitle(title: "Image and description")
              },
              {
                type: :partial,
                template: "decidim/design/components/cards/static-card-l-image"
              },
              {
                type: :text,
                values: ["Used by <i>Blogs</i> cards"]
              },
              {
                values: section_subtitle(title: "Description")
              },
              {
                type: :partial,
                template: "decidim/design/components/cards/static-card-l-description"
              },
              {
                type: :text,
                values: ["Used by <i>Debates</i> cards"]
              },
              {
                values: section_subtitle(title: "Use different template for the image block")
              },
              {
                type: :partial,
                template: "decidim/design/components/cards/static-card-l-meetings"
              },
              {
                type: :text,
                values: ["Used by <i>Meetings</i> cards"]
              },
              {
                values: section_subtitle(title: "Use the extra_data block")
              },
              {
                type: :partial,
                template: "decidim/design/components/cards/static-card-l-extra-data"
              },
              {
                type: :text,
                values: ["Used by <i>Accountability projects</i> cards. This card requires the module assets to display properly, i.e. <code>append_stylesheet_pack_tag \"decidim_accountability\"</code>"]
              },
              {
                type: :partial,
                template: "decidim/design/components/cards/static-card-l-extra-data-2"
              },
              {
                type: :text,
                values: ["Used by <i>Budget projects</i> cards. This card requires the module assets to display properly, i.e. <code>append_stylesheet_pack_tag \"decidim_budgets\"</code>"]
              }
            ]
          },
          {
            id: "source_code",
            contents: source_contents
          }
        ]
      end
      # rubocop:enable Layout/LineLength

      def source_contents
        dummy_resource = DummyClass.new(
          id: 1000,
          organization: current_organization,
          title: "Dummy resource title",
          description: "Dummy resource description"
        )

        contents = [
          { values: section_subtitle(title: "Generic cards") },
          cell_table_item("Card L", { cell: "decidim/card_l", args: [dummy_resource], call_string: 'cell("decidim/card_l", _RESOURCE_)' }),
          cell_table_item("Card G", { cell: "decidim/card_l", args: [dummy_resource], call_string: 'cell("decidim/card_g", _RESOURCE_)' }),
          cell_table_item("Card S", { cell: "decidim/card_l", args: [dummy_resource], call_string: 'cell("decidim/card_s", _RESOURCE_)' })
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
          { values: section_subtitle(title: "Accountability") },
          cell_table_item(
            "Result L",
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
          { values: section_subtitle(title: "Blogs") },
          cell_table_item(
            "Post L",
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
            "Post G",
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
            "Post S",
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
          { values: section_subtitle(title: "Budgets") },
          cell_table_item(
            "Project L",
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
            "Project S",
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
          { values: section_subtitle(title: "Debates") },
          cell_table_item(
            "Debate L",
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
            "Debate S",
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
          { values: section_subtitle(title: "Meetings") },
          cell_table_item(
            "Meeting L",
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
            "Meeting S",
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

        items << { values: section_subtitle(title: "Proposals") } if [proposal_resource, collaborative_draft_resource].any?(&:present?)

        if (resource = proposal_resource).present?
          items += [
            cell_table_item(
              "Proposal L",
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
              "Proposal S",
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
              "Collaborative Draft L",
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
          { values: section_subtitle(title: "Sortitions") },
          cell_table_item(
            "Sortition L",
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
          { values: section_subtitle(title: "Assemblies") },
          cell_table_item(
            "Assembly G",
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
            "Assembly S",
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
          { values: section_subtitle(title: "Conferences") },
          cell_table_item(
            "Conference G",
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
            "Conference S",
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
          { values: section_subtitle(title: "Initiatives") },
          cell_table_item(
            "Initiative G",
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
            "Initiative S",
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

        items << { values: section_subtitle(title: "Participatory Processes") } if [process_resource, process_group_resource].any?(&:present?)

        if (resource = process_resource).present?
          items += [
            cell_table_item(
              "Participatory Process G",
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
              "Participatory Process S",
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
              "Participatory Process Group G",
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
              "Participatory Process Group S",
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
