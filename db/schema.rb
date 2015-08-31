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

ActiveRecord::Schema.define(version: 20150830151511) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "agents", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone"
    t.string   "agent_id"
    t.string   "insurance_company_name"
    t.date     "dob"
    t.string   "bank_name"
    t.string   "account_name"
    t.string   "account_number"
    t.string   "branch_name"
    t.string   "branch_address"
    t.integer  "organisation_id"
    t.string   "email",                  default: "", null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.integer  "invitations_count",      default: 0
  end

  add_index "agents", ["email"], name: "index_agents_on_email", unique: true, using: :btree
  add_index "agents", ["invitation_token"], name: "index_agents_on_invitation_token", unique: true, using: :btree
  add_index "agents", ["invitations_count"], name: "index_agents_on_invitations_count", using: :btree
  add_index "agents", ["invited_by_id"], name: "index_agents_on_invited_by_id", using: :btree

  create_table "organisations", force: :cascade do |t|
    t.string   "name",                   default: "", null: false
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
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "referral_token"
    t.string   "locale"
  end

  add_index "organisations", ["email"], name: "index_organisations_on_email", unique: true, using: :btree
  add_index "organisations", ["reset_password_token"], name: "index_organisations_on_reset_password_token", unique: true, using: :btree

end
