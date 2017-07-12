# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170712072168) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "decidim_admin_participatory_process_user_roles", id: :serial, force: :cascade do |t|
    t.integer "decidim_user_id"
    t.integer "decidim_participatory_process_id"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["decidim_participatory_process_id", "decidim_user_id", "role"], name: "index_unique_user_and_process_role", unique: true
  end

  create_table "decidim_attachments", id: :serial, force: :cascade do |t|
    t.jsonb "title", null: false
    t.jsonb "description", null: false
    t.string "file", null: false
    t.string "content_type", null: false
    t.string "file_size", null: false
    t.integer "attached_to_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "attached_to_type", null: false
    t.index ["attached_to_id", "attached_to_type"], name: "index_decidim_attachments_on_attached_to"
  end

  create_table "decidim_authorizations", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.jsonb "metadata"
    t.integer "decidim_user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "unique_id"
    t.index ["decidim_user_id", "name"], name: "index_decidim_authorizations_on_decidim_user_id_and_name", unique: true
    t.index ["decidim_user_id"], name: "index_decidim_authorizations_on_decidim_user_id"
  end

  create_table "decidim_budgets_line_items", id: :serial, force: :cascade do |t|
    t.integer "decidim_order_id"
    t.integer "decidim_project_id"
    t.index ["decidim_order_id", "decidim_project_id"], name: "decidim_budgets_line_items_order_project_unique", unique: true
    t.index ["decidim_order_id"], name: "index_decidim_budgets_line_items_on_decidim_order_id"
    t.index ["decidim_project_id"], name: "index_decidim_budgets_line_items_on_decidim_project_id"
  end

  create_table "decidim_budgets_orders", id: :serial, force: :cascade do |t|
    t.integer "decidim_user_id"
    t.integer "decidim_feature_id"
    t.datetime "checked_out_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["decidim_feature_id"], name: "index_decidim_budgets_orders_on_decidim_feature_id"
    t.index ["decidim_user_id", "decidim_feature_id"], name: "decidim_budgets_order_user_feature_unique", unique: true
    t.index ["decidim_user_id"], name: "index_decidim_budgets_orders_on_decidim_user_id"
  end

  create_table "decidim_budgets_projects", id: :serial, force: :cascade do |t|
    t.jsonb "title"
    t.jsonb "description"
    t.integer "budget", null: false
    t.integer "decidim_feature_id"
    t.integer "decidim_scope_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "reference"
    t.index ["decidim_feature_id"], name: "index_decidim_budgets_projects_on_decidim_feature_id"
    t.index ["decidim_scope_id"], name: "index_decidim_budgets_projects_on_decidim_scope_id"
  end

  create_table "decidim_categories", id: :serial, force: :cascade do |t|
    t.jsonb "name", null: false
    t.jsonb "description", null: false
    t.integer "parent_id"
    t.integer "decidim_participatory_process_id"
    t.index ["decidim_participatory_process_id"], name: "index_decidim_categories_on_decidim_participatory_process_id"
    t.index ["parent_id"], name: "index_decidim_categories_on_parent_id"
  end

  create_table "decidim_categorizations", force: :cascade do |t|
    t.bigint "decidim_category_id", null: false
    t.string "categorizable_type"
    t.bigint "categorizable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["categorizable_type", "categorizable_id"], name: "decidim_categorizations_categorizable_id_and_type"
    t.index ["decidim_category_id"], name: "index_decidim_categorizations_on_decidim_category_id"
  end

  create_table "decidim_comments_comment_votes", id: :serial, force: :cascade do |t|
    t.integer "weight", null: false
    t.integer "decidim_comment_id", null: false
    t.integer "decidim_author_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["decidim_author_id"], name: "decidim_comments_comment_vote_author"
    t.index ["decidim_comment_id", "decidim_author_id"], name: "decidim_comments_comment_vote_comment_author_unique", unique: true
    t.index ["decidim_comment_id"], name: "decidim_comments_comment_vote_comment"
  end

  create_table "decidim_comments_comments", id: :serial, force: :cascade do |t|
    t.text "body", null: false
    t.string "decidim_commentable_type"
    t.integer "decidim_commentable_id", null: false
    t.integer "decidim_author_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "depth", default: 0, null: false
    t.integer "alignment", default: 0, null: false
    t.integer "decidim_user_group_id"
    t.string "decidim_root_commentable_type", null: false
    t.integer "decidim_root_commentable_id", null: false
    t.index ["created_at"], name: "index_decidim_comments_comments_on_created_at"
    t.index ["decidim_author_id"], name: "decidim_comments_comment_author"
    t.index ["decidim_commentable_type", "decidim_commentable_id"], name: "decidim_comments_comment_commentable"
    t.index ["decidim_root_commentable_type", "decidim_root_commentable_id"], name: "decidim_comments_comment_root_commentable"
  end

  create_table "decidim_features", id: :serial, force: :cascade do |t|
    t.string "manifest_name"
    t.jsonb "name"
    t.integer "decidim_participatory_process_id"
    t.jsonb "settings", default: {}
    t.integer "weight", default: 0
    t.jsonb "permissions"
    t.datetime "published_at"
    t.index ["decidim_participatory_process_id"], name: "index_decidim_features_on_decidim_participatory_process_id"
  end

  create_table "decidim_identities", id: :serial, force: :cascade do |t|
    t.string "provider", null: false
    t.string "uid", null: false
    t.integer "decidim_user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "decidim_organization_id"
    t.index ["decidim_organization_id"], name: "index_decidim_identities_on_decidim_organization_id"
    t.index ["decidim_user_id"], name: "index_decidim_identities_on_decidim_user_id"
    t.index ["provider", "uid", "decidim_organization_id"], name: "decidim_identities_provider_uid_organization_unique", unique: true
  end

  create_table "decidim_meetings_meetings", id: :serial, force: :cascade do |t|
    t.jsonb "title"
    t.jsonb "description"
    t.datetime "start_time"
    t.datetime "end_time"
    t.text "address"
    t.jsonb "location"
    t.jsonb "location_hints"
    t.integer "decidim_feature_id"
    t.integer "decidim_author_id"
    t.integer "decidim_scope_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "closing_report"
    t.integer "attendees_count"
    t.integer "contributions_count"
    t.text "attending_organizations"
    t.time "closed_at"
    t.float "latitude"
    t.float "longitude"
    t.string "reference"
    t.index ["decidim_author_id"], name: "index_decidim_meetings_meetings_on_decidim_author_id"
    t.index ["decidim_feature_id"], name: "index_decidim_meetings_meetings_on_decidim_feature_id"
    t.index ["decidim_scope_id"], name: "index_decidim_meetings_meetings_on_decidim_scope_id"
  end

  create_table "decidim_moderations", id: :serial, force: :cascade do |t|
    t.integer "decidim_participatory_process_id", null: false
    t.string "decidim_reportable_type"
    t.integer "decidim_reportable_id", null: false
    t.integer "report_count", default: 0, null: false
    t.datetime "hidden_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["decidim_participatory_process_id"], name: "decidim_moderations_participatory_process"
    t.index ["decidim_reportable_type", "decidim_reportable_id"], name: "decidim_moderations_reportable", unique: true
    t.index ["hidden_at"], name: "decidim_moderations_hidden_at"
    t.index ["report_count"], name: "decidim_moderations_report_count"
  end

  create_table "decidim_newsletters", id: :serial, force: :cascade do |t|
    t.jsonb "subject"
    t.jsonb "body"
    t.integer "organization_id"
    t.integer "author_id"
    t.integer "total_recipients"
    t.integer "total_deliveries"
    t.datetime "sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_decidim_newsletters_on_author_id"
    t.index ["organization_id"], name: "index_decidim_newsletters_on_organization_id"
  end

  create_table "decidim_organizations", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "host", null: false
    t.string "default_locale", null: false
    t.string "available_locales", default: [], array: true
    t.jsonb "welcome_text"
    t.string "homepage_image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "description"
    t.string "logo"
    t.string "twitter_handler"
    t.boolean "show_statistics", default: true
    t.string "favicon"
    t.string "instagram_handler"
    t.string "facebook_handler"
    t.string "youtube_handler"
    t.string "github_handler"
    t.string "official_img_header"
    t.string "official_img_footer"
    t.string "official_url"
    t.string "reference_prefix", null: false
    t.string "secondary_hosts", default: [], array: true
    t.string "available_authorizations", default: [], array: true
    t.index ["host"], name: "index_decidim_organizations_on_host", unique: true
    t.index ["name"], name: "index_decidim_organizations_on_name", unique: true
  end

  create_table "decidim_pages_pages", id: :serial, force: :cascade do |t|
    t.jsonb "body"
    t.integer "decidim_feature_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["decidim_feature_id"], name: "index_decidim_pages_pages_on_decidim_feature_id"
  end

  create_table "decidim_participatory_process_groups", id: :serial, force: :cascade do |t|
    t.jsonb "name", null: false
    t.jsonb "description", null: false
    t.string "hero_image"
    t.integer "decidim_organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["decidim_organization_id"], name: "decidim_participatory_process_group_organization"
  end

  create_table "decidim_participatory_process_steps", id: :serial, force: :cascade do |t|
    t.jsonb "title", null: false
    t.jsonb "description"
    t.date "start_date"
    t.date "end_date"
    t.integer "decidim_participatory_process_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: false
    t.integer "position"
    t.index ["decidim_participatory_process_id", "active"], name: "unique_index_to_avoid_duplicate_active_steps", unique: true, where: "(active = true)"
    t.index ["decidim_participatory_process_id", "position"], name: "index_unique_position_for_process", unique: true
    t.index ["decidim_participatory_process_id"], name: "index_decidim_processes_steps__on_decidim_process_id"
    t.index ["position"], name: "index_order_by_position_for_steps"
  end

  create_table "decidim_participatory_processes", id: :serial, force: :cascade do |t|
    t.string "slug", null: false
    t.string "hashtag"
    t.integer "decidim_organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "title", null: false
    t.jsonb "subtitle", null: false
    t.jsonb "short_description", null: false
    t.jsonb "description", null: false
    t.string "hero_image"
    t.string "banner_image"
    t.boolean "promoted", default: false
    t.datetime "published_at"
    t.jsonb "developer_group"
    t.date "end_date"
    t.jsonb "meta_scope"
    t.jsonb "local_area"
    t.jsonb "target"
    t.jsonb "participatory_scope"
    t.jsonb "participatory_structure"
    t.integer "decidim_scope_id"
    t.integer "decidim_participatory_process_group_id"
    t.index ["decidim_organization_id", "slug"], name: "index_unique_process_slug_and_organization", unique: true
    t.index ["decidim_organization_id"], name: "index_decidim_processes_on_decidim_organization_id"
  end

  create_table "decidim_proposals_proposal_votes", id: :serial, force: :cascade do |t|
    t.integer "decidim_proposal_id", null: false
    t.integer "decidim_author_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["decidim_author_id"], name: "decidim_proposals_proposal_vote_author"
    t.index ["decidim_proposal_id", "decidim_author_id"], name: "decidim_proposals_proposal_vote_proposal_author_unique", unique: true
    t.index ["decidim_proposal_id"], name: "decidim_proposals_proposal_vote_proposal"
  end

  create_table "decidim_proposals_proposals", id: :serial, force: :cascade do |t|
    t.text "title", null: false
    t.text "body", null: false
    t.integer "decidim_feature_id", null: false
    t.integer "decidim_author_id"
    t.integer "decidim_scope_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "proposal_votes_count", default: 0, null: false
    t.integer "decidim_user_group_id"
    t.string "state"
    t.datetime "answered_at"
    t.jsonb "answer"
    t.string "reference"
    t.text "address"
    t.float "latitude"
    t.float "longitude"
    t.index ["body"], name: "decidim_proposals_proposal_body_search"
    t.index ["created_at"], name: "index_decidim_proposals_proposals_on_created_at"
    t.index ["decidim_author_id"], name: "index_decidim_proposals_proposals_on_decidim_author_id"
    t.index ["decidim_feature_id"], name: "index_decidim_proposals_proposals_on_decidim_feature_id"
    t.index ["decidim_scope_id"], name: "index_decidim_proposals_proposals_on_decidim_scope_id"
    t.index ["proposal_votes_count"], name: "index_decidim_proposals_proposals_on_proposal_votes_count"
    t.index ["state"], name: "index_decidim_proposals_proposals_on_state"
    t.index ["title"], name: "decidim_proposals_proposal_title_search"
  end

  create_table "decidim_reports", id: :serial, force: :cascade do |t|
    t.integer "decidim_moderation_id", null: false
    t.integer "decidim_user_id", null: false
    t.string "reason", null: false
    t.text "details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["decidim_moderation_id", "decidim_user_id"], name: "decidim_reports_moderation_user_unique", unique: true
    t.index ["decidim_moderation_id"], name: "decidim_reports_moderation"
    t.index ["decidim_user_id"], name: "decidim_reports_user"
  end

  create_table "decidim_resource_links", id: :serial, force: :cascade do |t|
    t.string "from_type"
    t.integer "from_id", null: false
    t.string "to_type"
    t.integer "to_id", null: false
    t.string "name", null: false
    t.jsonb "data"
    t.index ["from_type", "from_id"], name: "index_decidim_resource_links_on_from_type_and_from_id"
    t.index ["name"], name: "index_decidim_resource_links_on_name"
    t.index ["to_type", "to_id"], name: "index_decidim_resource_links_on_to_type_and_to_id"
  end

  create_table "decidim_results_results", id: :serial, force: :cascade do |t|
    t.jsonb "title"
    t.jsonb "description"
    t.integer "decidim_feature_id"
    t.integer "decidim_scope_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "reference"
    t.index ["decidim_feature_id"], name: "index_decidim_results_results_on_decidim_feature_id"
    t.index ["decidim_scope_id"], name: "index_decidim_results_results_on_decidim_scope_id"
  end

  create_table "decidim_scopes", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.integer "decidim_organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["decidim_organization_id"], name: "index_decidim_scopes_on_decidim_organization_id"
    t.index ["name"], name: "index_decidim_scopes_on_name"
  end

  create_table "decidim_static_pages", id: :serial, force: :cascade do |t|
    t.jsonb "title", null: false
    t.string "slug", null: false
    t.jsonb "content", null: false
    t.integer "decidim_organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["decidim_organization_id"], name: "index_decidim_static_pages_on_decidim_organization_id"
  end

  create_table "decidim_surveys_survey_answers", id: :serial, force: :cascade do |t|
    t.jsonb "body", default: []
    t.integer "decidim_user_id"
    t.integer "decidim_survey_id"
    t.integer "decidim_survey_question_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["decidim_survey_id"], name: "index_decidim_surveys_survey_answers_on_decidim_survey_id"
    t.index ["decidim_survey_question_id"], name: "index_decidim_surveys_answers_question_id"
    t.index ["decidim_user_id"], name: "index_decidim_surveys_survey_answers_on_decidim_user_id"
  end

  create_table "decidim_surveys_survey_questions", id: :serial, force: :cascade do |t|
    t.jsonb "body"
    t.integer "decidim_survey_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position"
    t.boolean "mandatory"
    t.string "question_type"
    t.jsonb "answer_options", default: []
    t.index ["decidim_survey_id"], name: "index_decidim_surveys_survey_questions_on_decidim_survey_id"
  end

  create_table "decidim_surveys_surveys", id: :serial, force: :cascade do |t|
    t.jsonb "title"
    t.jsonb "description"
    t.jsonb "tos"
    t.integer "decidim_feature_id"
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["decidim_feature_id"], name: "index_decidim_surveys_surveys_on_decidim_feature_id"
  end

  create_table "decidim_system_admins", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_decidim_system_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_decidim_system_admins_on_reset_password_token", unique: true
  end

  create_table "decidim_user_group_memberships", id: :serial, force: :cascade do |t|
    t.integer "decidim_user_id", null: false
    t.integer "decidim_user_group_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["decidim_user_group_id"], name: "index_decidim_user_group_memberships_on_decidim_user_group_id"
    t.index ["decidim_user_id", "decidim_user_group_id"], name: "decidim_user_group_memberships_unique_user_and_group_ids", unique: true
    t.index ["decidim_user_id"], name: "index_decidim_user_group_memberships_on_decidim_user_id"
  end

  create_table "decidim_user_groups", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "document_number", null: false
    t.string "phone", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "avatar"
    t.datetime "rejected_at"
    t.integer "decidim_organization_id", null: false
    t.datetime "verified_at"
    t.index ["decidim_organization_id", "document_number"], name: "index_decidim_user_groups_document_number_on_organization_id", unique: true
    t.index ["decidim_organization_id", "name"], name: "index_decidim_user_groups_names_on_organization_id", unique: true
  end

  create_table "decidim_users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.integer "invited_by_id"
    t.integer "invitations_count", default: 0
    t.integer "decidim_organization_id"
    t.string "roles", default: [], array: true
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "name", null: false
    t.string "locale"
    t.string "avatar"
    t.boolean "comments_notifications", default: false, null: false
    t.boolean "replies_notifications", default: false, null: false
    t.boolean "newsletter_notifications", default: false, null: false
    t.text "delete_reason"
    t.datetime "deleted_at"
    t.index ["confirmation_token"], name: "index_decidim_users_on_confirmation_token", unique: true
    t.index ["decidim_organization_id"], name: "index_decidim_users_on_decidim_organization_id"
    t.index ["email", "decidim_organization_id"], name: "index_decidim_users_on_email_and_decidim_organization_id", unique: true, where: "(deleted_at IS NULL)"
    t.index ["invitation_token"], name: "index_decidim_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_decidim_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_decidim_users_on_invited_by_id"
    t.index ["reset_password_token"], name: "index_decidim_users_on_reset_password_token", unique: true
  end

  add_foreign_key "decidim_authorizations", "decidim_users"
  add_foreign_key "decidim_categorizations", "decidim_categories"
  add_foreign_key "decidim_identities", "decidim_organizations"
  add_foreign_key "decidim_newsletters", "decidim_users", column: "author_id"
  add_foreign_key "decidim_participatory_process_steps", "decidim_participatory_processes"
  add_foreign_key "decidim_participatory_processes", "decidim_organizations"
  add_foreign_key "decidim_scopes", "decidim_organizations"
  add_foreign_key "decidim_static_pages", "decidim_organizations"
  add_foreign_key "decidim_users", "decidim_organizations"
end
