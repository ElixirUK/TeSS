# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20151102133329) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", force: :cascade do |t|
    t.integer  "trackable_id"
    t.string   "trackable_type"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "key"
    t.text     "parameters"
    t.integer  "recipient_id"
    t.string   "recipient_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type", using: :btree
  add_index "activities", ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type", using: :btree
  add_index "activities", ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type", using: :btree

  create_table "content_providers", force: :cascade do |t|
    t.text     "title"
    t.text     "url"
    t.text     "logo_url"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "materials", force: :cascade do |t|
    t.text     "title"
    t.string   "url"
    t.string   "short_description"
    t.string   "doi"
    t.date     "remote_updated_date"
    t.date     "remote_created_date"
    t.date     "local_updated_date"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "internal_submitter_id"
    t.integer  "submitter_id"
    t.integer  "author_id"
    t.integer  "contributor_id"
    t.integer  "user_id"
  end

  create_table "nodes", force: :cascade do |t|
    t.string   "name"
    t.string   "member_status"
    t.string   "country_code"
    t.string   "home_page"
    t.string   "institutions",                 array: true
    t.string   "trc"
    t.string   "trc_email"
    t.string   "staff",                        array: true
    t.string   "twitter"
    t.string   "carousel_images",              array: true
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "profiles", force: :cascade do |t|
    t.text     "firstname"
    t.text     "surname"
    t.text     "image_url"
    t.text     "email"
    t.text     "website"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "user_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tate_annotation_attributes", force: :cascade do |t|
    t.string   "name",       null: false
    t.string   "identifier", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tate_annotation_attributes", ["name", "identifier"], name: "index_tate_annotation_attributes_on_name_and_identifier", using: :btree

  create_table "tate_annotation_value_seeds", force: :cascade do |t|
    t.integer  "attribute_id",                                            null: false
    t.string   "old_value"
    t.string   "tate_annotation_attributes",                              null: false
    t.string   "identifier",                                              null: false
    t.string   "value_type",                 limit: 50, default: "FIXME", null: false
    t.integer  "value_id",                              default: 0,       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tate_annotation_value_seeds", ["attribute_id"], name: "index_tate_annotation_value_seeds_on_attribute_id", using: :btree

  create_table "tate_annotation_versions", force: :cascade do |t|
    t.integer  "annotation_id",                                             null: false
    t.integer  "version",                                                   null: false
    t.integer  "version_creator_id"
    t.string   "source_type",                                               null: false
    t.integer  "source_id",                                                 null: false
    t.string   "annotatable_type",   limit: 50,                             null: false
    t.integer  "annotatable_id",                                            null: false
    t.integer  "attribute_id",                                              null: false
    t.string   "old_value"
    t.string   "value_type",         limit: 50, default: "Tate::TextValue", null: false
    t.integer  "value_id",                      default: 0,                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tate_annotation_versions", ["annotation_id"], name: "index_tate_annotation_versions_on_annotation_id", using: :btree

  create_table "tate_annotations", force: :cascade do |t|
    t.string   "source_type",                                               null: false
    t.integer  "source_id",                                                 null: false
    t.string   "annotatable_type",   limit: 50,                             null: false
    t.integer  "annotatable_id",                                            null: false
    t.integer  "attribute_id",                                              null: false
    t.string   "old_value"
    t.string   "value_type",         limit: 50, default: "Tate::TextValue", null: false
    t.integer  "value_id",                      default: 0,                 null: false
    t.integer  "version",                                                   null: false
    t.integer  "version_creator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tate_annotations", ["annotatable_type", "annotatable_id"], name: "index_tate_annotations_on_annotatable_type_and_annotatable_id", using: :btree
  add_index "tate_annotations", ["attribute_id"], name: "index_tate_annotations_on_attribute_id", using: :btree
  add_index "tate_annotations", ["source_type", "source_id"], name: "index_tate_annotations_on_source_type_and_source_id", using: :btree
  add_index "tate_annotations", ["value_type", "value_id"], name: "index_tate_annotations_on_value_type_and_value_id", using: :btree

  create_table "tate_number_value_versions", force: :cascade do |t|
    t.integer  "number_value_id",    null: false
    t.integer  "version",            null: false
    t.integer  "version_creator_id"
    t.integer  "number",             null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tate_number_value_versions", ["number_value_id"], name: "index_tate_number_value_versions_on_number_value_id", using: :btree

  create_table "tate_number_values", force: :cascade do |t|
    t.integer  "version",            null: false
    t.integer  "version_creator_id"
    t.integer  "number",             null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tate_text_value_versions", force: :cascade do |t|
    t.integer  "text_value_id",      null: false
    t.integer  "version",            null: false
    t.integer  "version_creator_id"
    t.text     "text",               null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tate_text_value_versions", ["text_value_id"], name: "index_tate_text_value_versions_on_text_value_id", using: :btree

  create_table "tate_text_values", force: :cascade do |t|
    t.integer  "version",            null: false
    t.integer  "version_creator_id"
    t.text     "text",               null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "username"
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "role_id"
    t.integer  "material_id"
    t.string   "authentication_token"
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["role_id"], name: "index_users_on_role_id", using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  create_table "workflows", force: :cascade do |t|
    t.string   "name"
    t.json     "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "users", "roles"
end
