# frozen_string_literal: true

module Decidim
  module Exporters
    # Inherits from abstract PDF exporter. This class is used to set
    # the parameters used to create a PDF when exporting Survey Answers.
    #
    class InitiativeVotesPDF < PDF
      def initialize(collection, initiative, serializer = Serializer)
        @initiative = initiative
        super(collection, serializer)
      end

      protected

      attr_reader :initiative

      def page_orientation
        if collect_user_extra_fields
          :landscape
        else
          :portrait
        end
      end

      def add_data!
        composer.formatted_text([translated_attribute(initiative.title)], style: :initiative_title)

        add_initiative_data
        add_signature_data
      end

      def styles
        {
          initiative_title: { font: bold_font, text_align: :center, font_size: 12, margin: [0, 0, 10, 0] },
          initiative_th: { font: bold_font, font_size: 10 },
          initiative_td: { font:, font_size: 10 },
          vote_th: { font: bold_font, font_size: 11 },
          vote_td: { font:, font_size: 10 }
        }
      end

      def add_initiative_data
        data_header = [
          layout.text(I18n.t("models.initiatives_votes.fields.initiative_id", scope: "decidim.admin"), style: :initiative_th),
          layout.text(I18n.t("models.initiatives_votes.fields.initiative_title", scope: "decidim.admin"), style: :initiative_th),
          layout.text(I18n.t("models.initiatives_votes.fields.initiative_start_date", scope: "decidim.admin"), style: :initiative_th),
          layout.text(I18n.t("models.initiatives_votes.fields.initiative_end_date", scope: "decidim.admin"), style: :initiative_th),
          layout.text(I18n.t("models.initiatives_votes.fields.initiative_signatures_count", scope: "decidim.admin"), style: :initiative_th)
        ]

        data_row = [
          layout.text(initiative.reference, style: :initiative_td),
          layout.text(translated_attribute(initiative.title), style: :initiative_td),
          layout.text(I18n.l(initiative.signature_start_date, format: :short), style: :initiative_td),
          layout.text(I18n.l(initiative.signature_end_date, format: :short), style: :initiative_td),
          layout.text(collection.count.to_s, style: :initiative_td)
        ]

        cells = [
          [layout.table([data_header], column_widths: [-1, -1.75, -0.55, -0.55, -1], cell_style: row_style)],
          [layout.table([data_row], column_widths: [-1, -1.75, -0.55, -0.55, -1], cell_style: row_style)]
        ]
        composer.table(cells, cell_style:)
      end

      def add_signature_data
        cells = [[layout.table([header], column_widths: signature_column_widths, cell_style: row_style)]]

        collection.map do |vote|
          cells.push([layout.table(vote_row(vote), column_widths: signature_column_widths, cell_style: row_style)])
        end

        composer.table(cells, margin: [20, 0, 0, 0], cell_style:)
      end

      def signature_column_widths
        if collect_user_extra_fields
          [-1, -1, -1, -0.75, -0.5, -0.5, -0.75, -0.75, -1, -0.75]
        else
          [-1, -1.25, -1, -0.5, -1.25, -1]
        end
      end

      def vote_row(model)
        cell = [
          layout.text(model.initiative.reference, style: :vote_td),
          layout.text(decidim_sanitize_translated(model.initiative.title), style: :vote_td)
        ]

        if collect_user_extra_fields
          metadata ||= model.encrypted_metadata ? encryptor.decrypt(model.encrypted_metadata) : {}

          cell += [
            layout.text(metadata[:name_and_surname].presence || "", style: :vote_td),
            layout.text(metadata[:document_number].presence || "", style: :vote_td),
            layout.text(metadata[:date_of_birth].presence || "", style: :vote_td),
            layout.text(metadata[:postal_code].presence || "", style: :vote_td)
          ]
        end

        cell += [
          layout.text(I18n.l(model.created_at, format: "%Y-%m-%d %H:%M:%S %Z"), style: :vote_td),
          layout.text((model.timestamp.presence || "").to_s, style: :vote_td),
          layout.text(model.hash_id, style: :vote_td),
          layout.text(scope(model), style: :vote_td)
        ]
        [cell]
      end

      def scope(model)
        return I18n.t("decidim.scopes.global") if model.decidim_scope_id.nil?
        return I18n.t("decidim.initiatives.unavailable_scope") if model.scope.blank?

        translated_attribute(model.scope.name)
      end

      def header
        header = [
          layout.text(I18n.t("models.initiatives_votes.fields.initiative_id", scope: "decidim.admin"), style: :vote_th),
          layout.text(I18n.t("models.initiatives_votes.fields.initiative_title", scope: "decidim.admin"), style: :vote_th)
        ]

        if collect_user_extra_fields
          header += [
            layout.text(I18n.t("models.initiatives_votes.fields.name_and_surname", scope: "decidim.admin"), style: :vote_th),
            layout.text(I18n.t("models.initiatives_votes.fields.document_number", scope: "decidim.admin"), style: :vote_th),
            layout.text(I18n.t("models.initiatives_votes.fields.date_of_birth", scope: "decidim.admin"), style: :vote_th),
            layout.text(I18n.t("models.initiatives_votes.fields.postal_code", scope: "decidim.admin"), style: :vote_th)
          ]
        end

        header += [
          layout.text(I18n.t("models.initiatives_votes.fields.time_and_date", scope: "decidim.admin"), style: :vote_th),
          layout.text(I18n.t("models.initiatives_votes.fields.timestamp", scope: "decidim.admin"), style: :vote_th),
          layout.text(I18n.t("models.initiatives_votes.fields.hash", scope: "decidim.admin"), style: :vote_th),
          layout.text(I18n.t("models.initiatives_votes.fields.scope", scope: "decidim.admin"), style: :vote_th)
        ]
        header
      end

      def collect_user_extra_fields = initiative.type.collect_user_extra_fields

      def cell_style
        lambda do |cell|
          cell.style.margin = 0
          cell.style.padding = 0
          cell.style.border(width: 1)
          cell.style.background_color = "cccccc" if cell.row.zero?
        end
      end

      def encryptor
        @encryptor ||= Decidim::Initiatives::DataEncryptor.new(secret: "personal user metadata")
      end

      def row_style
        { margin: 0, padding: [10, 0, 10, 5], border: { width: 0 } }
      end
    end
  end
end
