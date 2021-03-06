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

ActiveRecord::Schema.define(version: 20150214165526) do

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "filter_weights", force: true do |t|
    t.string   "name"
    t.float    "weight"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "friendships", force: true do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.integer  "rank",       default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "friendships", ["user_id", "friend_id"], name: "index_friendships_on_user_id_and_friend_id", unique: true, using: :btree

  create_table "movies", force: true do |t|
    t.decimal  "fb_id",              precision: 32, scale: 0
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "rank",                                        default: 0.0
    t.string   "poster"
    t.text     "plot"
    t.string   "genres"
    t.string   "imdb_id"
    t.date     "release_date"
    t.string   "cast_members"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
  end

  create_table "movies_users", id: false, force: true do |t|
    t.integer "movie_id"
    t.integer "user_id"
  end

  add_index "movies_users", ["movie_id", "user_id"], name: "index_movies_users_on_movie_id_and_user_id", using: :btree
  add_index "movies_users", ["movie_id"], name: "index_movies_users_on_movie_id", using: :btree
  add_index "movies_users", ["user_id"], name: "index_movies_users_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.decimal  "fb_id",      precision: 32, scale: 0
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rank",                                default: 0
  end

end
