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

ActiveRecord::Schema.define(version: 20150814050803) do

  create_table "aliases", force: :cascade do |t|
    t.string   "name"
    t.integer  "person_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "aliases", ["name"], name: "index_aliases_on_name"
  add_index "aliases", ["person_id"], name: "index_aliases_on_person_id"

  create_table "authorship_records", force: :cascade do |t|
    t.integer  "position"
    t.integer  "reference_id"
    t.integer  "person_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "authorship_records", ["person_id"], name: "index_authorship_records_on_person_id"
  add_index "authorship_records", ["reference_id"], name: "index_authorship_records_on_reference_id"

  create_table "bibfiles", force: :cascade do |t|
    t.string   "type"
    t.integer  "library_id"
    t.boolean  "import",                         default: true
    t.boolean  "processed",                      default: false
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.string   "references_source_file_name"
    t.string   "references_source_content_type"
    t.integer  "references_source_file_size"
    t.datetime "references_source_updated_at"
  end

  add_index "bibfiles", ["library_id"], name: "index_bibfiles_on_library_id"

  create_table "fields", force: :cascade do |t|
    t.string   "name"
    t.string   "value"
    t.integer  "reference_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "fields", ["reference_id"], name: "index_fields_on_reference_id"

  create_table "label_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id",   null: false
    t.integer "descendant_id", null: false
    t.integer "generations",   null: false
  end

  add_index "label_hierarchies", ["ancestor_id", "descendant_id", "generations"], name: "label_anc_desc_idx", unique: true
  add_index "label_hierarchies", ["descendant_id"], name: "label_desc_idx"

  create_table "labels", force: :cascade do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.integer  "count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "library_id"
  end

  add_index "labels", ["library_id"], name: "index_labels_on_library_id"
  add_index "labels", ["name"], name: "index_labels_on_name"
  add_index "labels", ["parent_id"], name: "index_labels_on_parent_id"

  create_table "labels_references", id: false, force: :cascade do |t|
    t.integer "label_id",     null: false
    t.integer "reference_id", null: false
  end

  create_table "libraries", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "user_id"
    t.string   "description"
    t.integer  "references_count", default: 0
  end

  add_index "libraries", ["user_id"], name: "index_libraries_on_user_id"

  create_table "links", force: :cascade do |t|
    t.integer  "reference_id"
    t.string   "kind"
    t.string   "uri"
    t.integer  "position"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "links", ["reference_id"], name: "index_links_on_reference_id"

  create_table "people", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "description"
  end

  add_index "people", ["description"], name: "index_people_on_description"

  create_table "raw_bibtex_entries", force: :cascade do |t|
    t.integer  "library_id"
    t.text     "content"
    t.integer  "reference_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.text     "messages"
    t.integer  "parent_record_id"
    t.string   "parent_record_type"
    t.boolean  "crossref_failure"
    t.string   "key"
    t.string   "crossrefkey"
    t.integer  "bibfile_id"
    t.integer  "num_warnings"
    t.integer  "num_errors"
    t.string   "digest"
    t.text     "fields"
    t.text     "links"
    t.text     "filenames"
    t.text     "authors"
    t.string   "authorship_type"
    t.string   "bibtex_type"
  end

  add_index "raw_bibtex_entries", ["bibfile_id"], name: "index_raw_bibtex_entries_on_bibfile_id"
  add_index "raw_bibtex_entries", ["crossref_failure"], name: "index_raw_bibtex_entries_on_crossref_failure"
  add_index "raw_bibtex_entries", ["digest"], name: "index_raw_bibtex_entries_on_digest"
  add_index "raw_bibtex_entries", ["key"], name: "index_raw_bibtex_entries_on_key"
  add_index "raw_bibtex_entries", ["library_id"], name: "index_raw_bibtex_entries_on_library_id"
  add_index "raw_bibtex_entries", ["parent_record_id"], name: "index_raw_bibtex_entries_on_parent_record_id"
  add_index "raw_bibtex_entries", ["reference_id"], name: "index_raw_bibtex_entries_on_reference_id"

  create_table "references", force: :cascade do |t|
    t.string   "key"
    t.string   "title"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "library_id"
    t.string   "authorship_type"
    t.integer  "parent_id"
    t.string   "bibtex_type"
    t.integer  "year"
    t.integer  "resources_count", default: 0
    t.integer  "links_count",     default: 0
    t.string   "month"
    t.string   "doi"
    t.text     "authors"
  end

  add_index "references", ["doi"], name: "index_references_on_doi"
  add_index "references", ["library_id"], name: "index_references_on_library_id"
  add_index "references", ["parent_id"], name: "index_references_on_parent_id"

  create_table "resources", force: :cascade do |t|
    t.string   "type"
    t.string   "name"
    t.string   "hash"
    t.integer  "position"
    t.integer  "library_id"
    t.integer  "reference_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "resources", ["library_id"], name: "index_resources_on_library_id"
  add_index "resources", ["reference_id"], name: "index_resources_on_reference_id"

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", force: :cascade do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "description"
    t.string   "name"
    t.string   "provider"
    t.string   "uid"
    t.text     "google_credentials"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["provider"], name: "index_users_on_provider"
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  add_index "users", ["uid"], name: "index_users_on_uid"

end
