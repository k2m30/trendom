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

ActiveRecord::Schema.define(version: 20160914121626) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "campaigns", force: :cascade do |t|
    t.string   "name"
    t.boolean  "sent",              default: false
    t.datetime "date_sent"
    t.float    "progress",          default: 0.0
    t.integer  "email_template_id",                 null: false
    t.integer  "user_id"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "subject"
    t.integer  "profiles_ids",      default: [],                 array: true
  end

  create_table "email_templates", force: :cascade do |t|
    t.string   "name"
    t.text     "text"
    t.integer  "user_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "subject",    default: ""
  end

  create_table "profiles", force: :cascade do |t|
    t.string   "name"
    t.string   "position"
    t.string   "photo"
    t.string   "location"
    t.text     "notes"
    t.string   "linkedin_url"
    t.string   "twitter_url"
    t.string   "facebook_url"
    t.integer  "linkedin_id"
    t.integer  "twitter_id"
    t.integer  "facebook_id"
    t.integer  "emails_available"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "emails",           default: [], array: true
    t.integer  "source",           default: 0
    t.integer  "verified",         default: 0
    t.index ["facebook_id"], name: "index_profiles_on_facebook_id", using: :btree
    t.index ["linkedin_id"], name: "index_profiles_on_linkedin_id", using: :btree
    t.index ["twitter_id"], name: "index_profiles_on_twitter_id", using: :btree
  end

  create_table "profiles_users", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "profile_id"
    t.index ["profile_id"], name: "index_profiles_users_on_profile_id", using: :btree
    t.index ["user_id"], name: "index_profiles_users_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                default: "",  null: false
    t.string   "encrypted_password",   default: "",  null: false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",        default: 0,   null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "name"
    t.string   "image"
    t.string   "uid"
    t.string   "plan",                 default: ""
    t.datetime "subscription_expires"
    t.string   "card_holder_name"
    t.string   "street_address"
    t.string   "street_address2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "country"
    t.string   "billing_email"
    t.string   "phone"
    t.string   "card_number"
    t.integer  "calls_left",           default: 0
    t.float    "progress",             default: 0.0
    t.string   "tkn"
    t.integer  "expires_at"
    t.integer  "revealed_ids",         default: [],               array: true
    t.integer  "campaigns_sent_ids",   default: [],               array: true
    t.string   "order_number"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
  end

end
