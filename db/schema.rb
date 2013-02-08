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
# It's strongly recommended to check this file into your version control system.

<<<<<<< HEAD
ActiveRecord::Schema.define(:version => 20120824185714) do
=======
ActiveRecord::Schema.define(:version => 20130108221731) do
>>>>>>> upstream/shared_calendar

  create_table "account_users", :force => true do |t|
    t.integer  "account_id",               :precision => 38, :scale => 0, :null => false
    t.integer  "user_id",                  :precision => 38, :scale => 0, :null => false
    t.string   "user_role",  :limit => 50,                                :null => false
    t.datetime "created_at",                                              :null => false
    t.integer  "created_by",               :precision => 38, :scale => 0, :null => false
    t.datetime "deleted_at"
    t.integer  "deleted_by",               :precision => 38, :scale => 0
  end


  create_table "accounts", :force => true do |t|
    t.string   "type",                   :limit => 50,                                 :null => false
    t.string   "account_number",         :limit => 50,                                 :null => false
    t.string   "description",            :limit => 50,                                 :null => false
    t.datetime "expires_at",                                                           :null => false
    t.string   "name_on_card",           :limit => 200
    t.integer  "expiration_month",                      :precision => 38, :scale => 0
    t.integer  "expiration_year",                       :precision => 38, :scale => 0
    t.datetime "created_at",                                                           :null => false
    t.integer  "created_by",                            :precision => 38, :scale => 0, :null => false
    t.datetime "updated_at"
    t.integer  "updated_by",                            :precision => 38, :scale => 0
    t.datetime "suspended_at"
    t.text     "remittance_information"
    t.integer  "facility_id",                           :precision => 38, :scale => 0
    t.integer  "affiliate_id",                          :precision => 38, :scale => 0
    t.string   "affiliate_other"
  end

  add_index "accounts", ["affiliate_id"], :name => "index_accounts_on_affiliate_id", :tablespace => "bc_nucore"


  create_table "affiliates", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bi_netids", :force => true do |t|
    t.string  "netid",                                      :null => false
    t.integer "facility_id", :precision => 38, :scale => 0, :null => false
  end

  add_index "bi_netids", ["facility_id"], :name => "index_bi_netids_on_facility_id", :tablespace => "bc_nucore"
  add_index "bi_netids", ["netid"], :name => "index_bi_netids_on_netid", :tablespace => "bc_nucore"


  create_table "budgeted_chart_strings", :force => true do |t|
    t.string   "fund",       :limit => 20, :null => false
    t.string   "dept",       :limit => 20, :null => false
    t.string   "project",    :limit => 20
    t.string   "activity",   :limit => 20
    t.string   "account",    :limit => 20
    t.datetime "starts_at",                :null => false
    t.datetime "expires_at",               :null => false
  end

  create_table "bundle_products", :force => true do |t|
    t.integer "bundle_product_id", :precision => 38, :scale => 0, :null => false
    t.integer "product_id",        :precision => 38, :scale => 0, :null => false
    t.integer "quantity",          :precision => 38, :scale => 0, :null => false
  end


  create_table "external_service_passers", :force => true do |t|
    t.integer  "external_service_id", :precision => 38, :scale => 0
    t.integer  "passer_id",           :precision => 38, :scale => 0
    t.string   "passer_type"
    t.boolean  "active",              :precision => 1,  :scale => 0, :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "external_service_receivers", :force => true do |t|
    t.integer  "external_service_id", :precision => 38, :scale => 0
    t.integer  "receiver_id",         :precision => 38, :scale => 0
    t.string   "receiver_type"
    t.string   "response_data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "external_services", :force => true do |t|
    t.string   "type"
    t.string   "location"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "facilities", :force => true do |t|
    t.string   "name",              :limit => 200,                                                  :null => false
    t.string   "abbreviation",      :limit => 50,                                                   :null => false
    t.string   "url_name",          :limit => 50,                                                   :null => false
    t.boolean  "is_active",                        :precision => 1, :scale => 0,                    :null => false
    t.datetime "created_at",                                                                        :null => false
    t.datetime "updated_at",                                                                        :null => false
    t.text     "description"
    t.boolean  "accepts_cc",                       :precision => 1, :scale => 0, :default => true
    t.boolean  "accepts_po",                       :precision => 1, :scale => 0, :default => true
    t.text     "short_description",                                                                 :null => false
    t.text     "address"
    t.string   "phone_number"
    t.string   "fax_number"
    t.string   "email"
    t.string   "journal_mask",      :limit => 50,                                                   :null => false
    t.boolean  "accepts_multi_add",                :precision => 1, :scale => 0, :default => false, :null => false
  end

  add_index "facilities", ["abbreviation"], :name => "sys_c008532", :unique => true, :tablespace => "bc_nucore"
  add_index "facilities", ["name"], :name => "sys_c008531", :unique => true, :tablespace => "bc_nucore"
  add_index "facilities", ["url_name"], :name => "sys_c008533", :unique => true, :tablespace => "bc_nucore"

  create_table "facility_accounts", :force => true do |t|
    t.integer  "facility_id",                   :precision => 38, :scale => 0, :null => false
    t.string   "account_number",  :limit => 50,                                :null => false
    t.boolean  "is_active",                     :precision => 1,  :scale => 0, :null => false
    t.integer  "created_by",                    :precision => 38, :scale => 0, :null => false
    t.datetime "created_at",                                                   :null => false
    t.integer  "revenue_account",               :precision => 38, :scale => 0, :null => false
  end


  create_table "file_uploads", :force => true do |t|
    t.integer  "order_detail_id",                  :precision => 38, :scale => 0
    t.integer  "product_id",                       :precision => 38, :scale => 0
    t.string   "name",              :limit => 200,                                :null => false
    t.string   "file_type",         :limit => 50,                                 :null => false
    t.integer  "created_by",                       :precision => 38, :scale => 0, :null => false
    t.datetime "created_at",                                                      :null => false
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size",                   :precision => 38, :scale => 0
    t.datetime "file_updated_at"
  end


  create_table "instrument_statuses", :force => true do |t|
    t.integer  "instrument_id", :precision => 38, :scale => 0, :null => false
    t.boolean  "is_on",         :precision => 1,  :scale => 0, :null => false
    t.datetime "created_at",                                   :null => false
  end


  create_table "journal_rows", :force => true do |t|
    t.integer "journal_id",                     :precision => 38, :scale => 0, :null => false
    t.integer "order_detail_id",                :precision => 38, :scale => 0
    t.decimal "amount",                         :precision => 9,  :scale => 2, :null => false
    t.string  "description",     :limit => 200
    t.string  "reference",       :limit => 50
    t.string  "fund",            :limit => 3,                                  :null => false
    t.string  "dept",            :limit => 7,                                  :null => false
    t.string  "project",         :limit => 8
    t.string  "activity",        :limit => 2
    t.string  "program",         :limit => 4
    t.string  "account",         :limit => 5
  end

  create_table "journals", :force => true do |t|
    t.integer  "facility_id",                      :precision => 38, :scale => 0
    t.string   "reference",         :limit => 50
    t.string   "description",       :limit => 200
    t.boolean  "is_successful",                    :precision => 1,  :scale => 0
    t.integer  "created_by",                       :precision => 38, :scale => 0, :null => false
    t.datetime "created_at",                                                      :null => false
    t.integer  "updated_by",                       :precision => 38, :scale => 0
    t.datetime "updated_at"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size",                   :precision => 38, :scale => 0
    t.datetime "file_updated_at"
    t.datetime "journal_date",                                                    :null => false
  end

  create_table "notifications", :force => true do |t|
    t.string    "type",                                                     :null => false
    t.integer   "subject_id",                :precision => 38, :scale => 0, :null => false
    t.string    "subject_type",                                             :null => false
    t.integer   "user_id",                   :precision => 38, :scale => 0, :null => false
    t.string    "notice",                                                   :null => false
    t.timestamp "dismissed_at", :limit => 6
    t.datetime  "created_at"
    t.datetime  "updated_at"
  end

  create_table "nucs_accounts", :force => true do |t|
    t.string "value",     :limit => 16,  :null => false
    t.string "auxiliary", :limit => 512
  end

  add_index "nucs_accounts", ["value"], :name => "index_nucs_accounts_on_value", :tablespace => "bc_nucore"

  create_table "nucs_chart_field1s", :force => true do |t|
    t.string "value",     :limit => 16,  :null => false
    t.string "auxiliary", :limit => 512
  end

  add_index "nucs_chart_field1s", ["value"], :name => "i_nucs_chart_field1s_value", :tablespace => "bc_nucore"

  create_table "nucs_departments", :force => true do |t|
    t.string "value",     :limit => 16,  :null => false
    t.string "auxiliary", :limit => 512
  end

  add_index "nucs_departments", ["value"], :name => "i_nucs_departments_value", :tablespace => "bc_nucore"

  create_table "nucs_funds", :force => true do |t|
    t.string "value",     :limit => 8,   :null => false
    t.string "auxiliary", :limit => 512
  end

  add_index "nucs_funds", ["value"], :name => "index_nucs_funds_on_value", :tablespace => "bc_nucore"

  create_table "nucs_gl066s", :force => true do |t|
    t.string   "budget_period", :limit => 8,  :null => false
    t.string   "fund",          :limit => 8,  :null => false
    t.string   "department",    :limit => 16, :null => false
    t.string   "project",       :limit => 16, :null => false
    t.string   "activity",      :limit => 16, :null => false
    t.string   "account",       :limit => 16, :null => false
    t.datetime "starts_at"
    t.datetime "expires_at"
  end

  add_index "nucs_gl066s", ["account"], :name => "index_nucs_gl066s_on_account", :tablespace => "bc_nucore"
  add_index "nucs_gl066s", ["activity"], :name => "index_nucs_gl066s_on_activity", :tablespace => "bc_nucore"
  add_index "nucs_gl066s", ["department"], :name => "i_nucs_gl066s_department", :tablespace => "bc_nucore"
  add_index "nucs_gl066s", ["fund"], :name => "index_nucs_gl066s_on_fund", :tablespace => "bc_nucore"
  add_index "nucs_gl066s", ["project"], :name => "index_nucs_gl066s_on_project", :tablespace => "bc_nucore"

  create_table "nucs_grants_budget_trees", :force => true do |t|
    t.string   "account",              :limit => 16, :null => false
    t.string   "account_desc",         :limit => 32, :null => false
    t.string   "roll_up_node",         :limit => 32, :null => false
    t.string   "roll_up_node_desc",    :limit => 32, :null => false
    t.string   "parent_node",          :limit => 32, :null => false
    t.string   "parent_node_desc",     :limit => 32, :null => false
    t.datetime "account_effective_at",               :null => false
    t.string   "tree",                 :limit => 32, :null => false
    t.datetime "tree_effective_at",                  :null => false
  end

  add_index "nucs_grants_budget_trees", ["account"], :name => "i_nuc_gra_bud_tre_acc", :tablespace => "bc_nucore"

  create_table "nucs_programs", :force => true do |t|
    t.string "value",     :limit => 8,   :null => false
    t.string "auxiliary", :limit => 512
  end

  add_index "nucs_programs", ["value"], :name => "index_nucs_programs_on_value", :tablespace => "bc_nucore"

  create_table "nucs_project_activities", :force => true do |t|
    t.string "project",   :limit => 16,  :null => false
    t.string "activity",  :limit => 16,  :null => false
    t.string "auxiliary", :limit => 512
  end

  add_index "nucs_project_activities", ["activity"], :name => "i_nuc_pro_act_act", :tablespace => "bc_nucore"
  add_index "nucs_project_activities", ["project"], :name => "i_nuc_pro_act_pro", :tablespace => "bc_nucore"

  create_table "order_details", :force => true do |t|
    t.integer  "order_id",                               :precision => 38, :scale => 0, :null => false
    t.integer  "product_id",                             :precision => 38, :scale => 0, :null => false
    t.integer  "quantity",                               :precision => 38, :scale => 0, :null => false
    t.integer  "price_policy_id",                        :precision => 38, :scale => 0
    t.decimal  "actual_cost",                            :precision => 10, :scale => 2
    t.decimal  "actual_subsidy",                         :precision => 10, :scale => 2
    t.integer  "assigned_user_id",                       :precision => 38, :scale => 0
    t.decimal  "estimated_cost",                         :precision => 10, :scale => 2
    t.decimal  "estimated_subsidy",                      :precision => 10, :scale => 2
    t.integer  "account_id",                             :precision => 38, :scale => 0
    t.datetime "dispute_at"
    t.string   "dispute_reason",          :limit => 200
    t.datetime "dispute_resolved_at"
    t.string   "dispute_resolved_reason", :limit => 200
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "order_status_id",                        :precision => 38, :scale => 0
    t.string   "state",                   :limit => 50
    t.integer  "response_set_id",                        :precision => 38, :scale => 0
    t.integer  "group_id",                               :precision => 38, :scale => 0
    t.integer  "bundle_product_id",                      :precision => 38, :scale => 0
    t.string   "note",                    :limit => 100
    t.datetime "fulfilled_at"
    t.datetime "reviewed_at"
    t.integer  "statement_id",                           :precision => 38, :scale => 0
    t.integer  "journal_id",                             :precision => 38, :scale => 0
    t.string   "reconciled_note"
    t.integer  "created_by",                             :precision => 38, :scale => 0, :null => false
  end


  create_table "order_statuses", :force => true do |t|
    t.string  "name",        :limit => 50,                                :null => false
    t.integer "facility_id",               :precision => 38, :scale => 0
    t.integer "parent_id",                 :precision => 38, :scale => 0
    t.integer "lft",                       :precision => 38, :scale => 0
    t.integer "rgt",                       :precision => 38, :scale => 0
  end

  add_index "order_statuses", ["facility_id", "parent_id", "name"], :name => "sys_c008542", :unique => true, :tablespace => "bc_nucore"

  create_table "orders", :force => true do |t|
    t.integer  "account_id",                        :precision => 38, :scale => 0
    t.integer  "user_id",                           :precision => 38, :scale => 0, :null => false
    t.integer  "created_by",                        :precision => 38, :scale => 0, :null => false
    t.datetime "created_at",                                                       :null => false
    t.datetime "updated_at",                                                       :null => false
    t.datetime "ordered_at"
    t.integer  "facility_id",                       :precision => 38, :scale => 0
    t.string   "state",               :limit => 50
    t.integer  "merge_with_order_id",               :precision => 38, :scale => 0
  end


  create_table "price_group_members", :force => true do |t|
    t.string  "type",           :limit => 50,                                :null => false
    t.integer "price_group_id",               :precision => 38, :scale => 0, :null => false
    t.integer "user_id",                      :precision => 38, :scale => 0
    t.integer "account_id",                   :precision => 38, :scale => 0
  end


  create_table "price_group_products", :force => true do |t|
    t.integer  "price_group_id",     :precision => 38, :scale => 0, :null => false
    t.integer  "product_id",         :precision => 38, :scale => 0, :null => false
    t.integer  "reservation_window", :precision => 38, :scale => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "price_group_products", ["price_group_id"], :name => "i_pri_gro_pro_pri_gro_id", :tablespace => "bc_nucore"
  add_index "price_group_products", ["product_id"], :name => "i_pri_gro_pro_pro_id", :tablespace => "bc_nucore"

  create_table "price_groups", :force => true do |t|
    t.integer "facility_id",                 :precision => 38, :scale => 0
    t.string  "name",          :limit => 50,                                :null => false
    t.integer "display_order",               :precision => 38, :scale => 0, :null => false
    t.boolean "is_internal",                 :precision => 1,  :scale => 0, :null => false
  end

  add_index "price_groups", ["facility_id", "name"], :name => "sys_c008577", :unique => true, :tablespace => "bc_nucore"


  create_table "price_policies", :force => true do |t|
    t.string   "type",                :limit => 50,                                                   :null => false
    t.integer  "price_group_id",                    :precision => 38, :scale => 0,                    :null => false
    t.datetime "start_date",                                                                          :null => false
    t.decimal  "unit_cost",                         :precision => 10, :scale => 2
    t.decimal  "unit_subsidy",                      :precision => 10, :scale => 2
    t.decimal  "usage_rate",                        :precision => 10, :scale => 2
    t.integer  "usage_mins",                        :precision => 38, :scale => 0
    t.decimal  "reservation_rate",                  :precision => 10, :scale => 2
    t.integer  "reservation_mins",                  :precision => 38, :scale => 0
    t.decimal  "overage_rate",                      :precision => 10, :scale => 2
    t.integer  "overage_mins",                      :precision => 38, :scale => 0
    t.decimal  "minimum_cost",                      :precision => 10, :scale => 2
    t.decimal  "cancellation_cost",                 :precision => 10, :scale => 2
    t.decimal  "usage_subsidy",                     :precision => 10, :scale => 2
    t.decimal  "reservation_subsidy",               :precision => 10, :scale => 2
    t.decimal  "overage_subsidy",                   :precision => 10, :scale => 2
    t.datetime "expire_date",                                                                         :null => false
    t.integer  "product_id",                        :precision => 38, :scale => 0
    t.boolean  "can_purchase",                      :precision => 1,  :scale => 0, :default => false, :null => false
  end


  create_table "product_access_groups", :force => true do |t|
    t.integer  "product_id", :precision => 38, :scale => 0, :null => false
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "product_access_schedule_rules", :id => false, :force => true do |t|
    t.integer "product_access_group_id", :precision => 38, :scale => 0, :null => false
    t.integer "schedule_rule_id",        :precision => 38, :scale => 0, :null => false
  end

  create_table "product_accessories", :force => true do |t|
    t.integer "product_id",   :precision => 38, :scale => 0, :null => false
    t.integer "accessory_id", :precision => 38, :scale => 0, :null => false
  end

  create_table "product_users", :force => true do |t|
    t.integer  "product_id",              :precision => 38, :scale => 0, :null => false
    t.integer  "user_id",                 :precision => 38, :scale => 0, :null => false
    t.integer  "approved_by",             :precision => 38, :scale => 0, :null => false
    t.datetime "approved_at",                                            :null => false
    t.integer  "product_access_group_id", :precision => 38, :scale => 0
  end


  create_table "products", :force => true do |t|
    t.string   "type",                    :limit => 50,                                                    :null => false
    t.integer  "facility_id",                            :precision => 38, :scale => 0,                    :null => false
    t.string   "name",                    :limit => 200,                                                   :null => false
    t.string   "url_name",                :limit => 50,                                                    :null => false
    t.text     "description"
<<<<<<< HEAD
    t.boolean  "requires_approval",                      :precision => 1,  :scale => 0,                    :null => false
    t.integer  "initial_order_status_id",                :precision => 38, :scale => 0
    t.boolean  "is_archived",                            :precision => 1,  :scale => 0,                    :null => false
    t.boolean  "is_hidden",                              :precision => 1,  :scale => 0,                    :null => false
    t.datetime "created_at",                                                                               :null => false
    t.datetime "updated_at",                                                                               :null => false
    t.integer  "min_reserve_mins",                       :precision => 38, :scale => 0
    t.integer  "max_reserve_mins",                       :precision => 38, :scale => 0
    t.integer  "min_cancel_hours",                       :precision => 38, :scale => 0
    t.integer  "facility_account_id",                    :precision => 38, :scale => 0
=======
    t.integer  "schedule_id"
    t.boolean  "requires_approval",                                         :null => false
    t.integer  "initial_order_status_id"
    t.boolean  "is_archived",                                               :null => false
    t.boolean  "is_hidden",                                                 :null => false
    t.datetime "created_at",                                                :null => false
    t.datetime "updated_at",                                                :null => false
    t.integer  "min_reserve_mins"
    t.integer  "max_reserve_mins"
    t.integer  "min_cancel_hours"
    t.integer  "facility_account_id"
>>>>>>> upstream/shared_calendar
    t.string   "account",                 :limit => 5
    t.boolean  "show_details",                           :precision => 1,  :scale => 0, :default => false, :null => false
    t.integer  "auto_cancel_mins",                       :precision => 38, :scale => 0
    t.string   "contact_email"
  end

<<<<<<< HEAD
=======
  add_index "products", ["facility_account_id"], :name => "fk_facility_accounts"
  add_index "products", ["facility_id"], :name => "sys_c008556"
  add_index "products", ["schedule_id"], :name => "i_instruments_schedule_id"
>>>>>>> upstream/shared_calendar

  create_table "relays", :force => true do |t|
    t.integer  "instrument_id",               :precision => 38, :scale => 0
    t.string   "ip",            :limit => 15
    t.integer  "port",                        :precision => 38, :scale => 0
    t.string   "username",      :limit => 50
    t.string   "password",      :limit => 50
    t.boolean  "auto_logout",                 :precision => 1,  :scale => 0
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "relays", ["instrument_id"], :name => "index_relays_on_instrument_id", :tablespace => "bc_nucore"

  create_table "reservations", :force => true do |t|
<<<<<<< HEAD
    t.integer  "order_detail_id",                :precision => 38, :scale => 0
    t.integer  "instrument_id",                  :precision => 38, :scale => 0, :null => false
    t.datetime "reserve_start_at",                                              :null => false
    t.datetime "reserve_end_at",                                                :null => false
=======
    t.integer  "order_detail_id"
    t.integer  "product_id",                     :null => false
    t.datetime "reserve_start_at",               :null => false
    t.datetime "reserve_end_at",                 :null => false
>>>>>>> upstream/shared_calendar
    t.datetime "actual_start_at"
    t.datetime "actual_end_at"
    t.datetime "canceled_at"
    t.integer  "canceled_by",                    :precision => 38, :scale => 0
    t.string   "canceled_reason",  :limit => 50
  end

<<<<<<< HEAD
=======
  add_index "reservations", ["order_detail_id"], :name => "res_ord_det_id_fk"
  add_index "reservations", ["product_id"], :name => "reservations_instrument_id_fk"

  create_table "roles", :force => true do |t|
    t.string "name"
  end
>>>>>>> upstream/shared_calendar

  create_table "schedule_rules", :force => true do |t|
    t.integer "instrument_id",    :precision => 38, :scale => 0,                  :null => false
    t.decimal "discount_percent", :precision => 10, :scale => 2, :default => 0.0, :null => false
    t.integer "start_hour",       :precision => 38, :scale => 0,                  :null => false
    t.integer "start_min",        :precision => 38, :scale => 0,                  :null => false
    t.integer "end_hour",         :precision => 38, :scale => 0,                  :null => false
    t.integer "end_min",          :precision => 38, :scale => 0,                  :null => false
    t.integer "duration_mins",    :precision => 38, :scale => 0,                  :null => false
    t.boolean "on_sun",           :precision => 1,  :scale => 0,                  :null => false
    t.boolean "on_mon",           :precision => 1,  :scale => 0,                  :null => false
    t.boolean "on_tue",           :precision => 1,  :scale => 0,                  :null => false
    t.boolean "on_wed",           :precision => 1,  :scale => 0,                  :null => false
    t.boolean "on_thu",           :precision => 1,  :scale => 0,                  :null => false
    t.boolean "on_fri",           :precision => 1,  :scale => 0,                  :null => false
    t.boolean "on_sat",           :precision => 1,  :scale => 0,                  :null => false
  end


  create_table "schedules", :force => true do |t|
    t.string   "name"
    t.integer  "facility_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "schedules", ["facility_id"], :name => "i_schedules_facility_id"

  create_table "statement_rows", :force => true do |t|
    t.integer  "statement_id",    :precision => 38, :scale => 0, :null => false
    t.integer  "order_detail_id", :precision => 38, :scale => 0, :null => false
    t.decimal  "amount",          :precision => 10, :scale => 2, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "statements", :force => true do |t|
    t.integer  "facility_id", :precision => 38, :scale => 0, :null => false
    t.integer  "created_by",  :precision => 38, :scale => 0, :null => false
    t.datetime "created_at",                                 :null => false
    t.integer  "account_id",  :precision => 38, :scale => 0, :null => false
  end


  create_table "user_roles", :force => true do |t|
    t.integer "user_id",     :precision => 38, :scale => 0, :null => false
    t.integer "facility_id", :precision => 38, :scale => 0
    t.string  "role",                                       :null => false
  end

  add_index "user_roles", ["user_id", "facility_id", "role"], :name => "i_use_rol_use_id_fac_id_rol", :tablespace => "bc_nucore"

  create_table "users", :force => true do |t|
    t.string   "username",                                                              :null => false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email",                                                 :default => "", :null => false
    t.string   "encrypted_password"
    t.string   "password_salt"
    t.integer  "sign_in_count",          :precision => 38, :scale => 0, :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.integer  "uid",                    :precision => 38, :scale => 0
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true, :tablespace => "bc_nucore"
  add_index "users", ["uid"], :name => "index_users_on_uid", :tablespace => "bc_nucore"
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true, :tablespace => "bc_nucore"

  create_table "versions", :force => true do |t|
    t.integer  "versioned_id",      :precision => 38, :scale => 0
    t.string   "versioned_type"
    t.integer  "user_id",           :precision => 38, :scale => 0
    t.string   "user_type"
    t.string   "user_name"
    t.text     "modifications"
    t.integer  "version_number",    :precision => 38, :scale => 0
    t.string   "tag"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "reason_for_update"
    t.integer  "reverted_from",     :precision => 38, :scale => 0
    t.string   "commit_label"
  end

  add_index "versions", ["commit_label"], :name => "index_versions_on_commit_label", :tablespace => "bc_nucore"
  add_index "versions", ["created_at"], :name => "index_versions_on_created_at", :tablespace => "bc_nucore"
  add_index "versions", ["tag"], :name => "index_versions_on_tag", :tablespace => "bc_nucore"
  add_index "versions", ["user_id", "user_type"], :name => "i_versions_user_id_user_type", :tablespace => "bc_nucore"
  add_index "versions", ["user_name"], :name => "index_versions_on_user_name", :tablespace => "bc_nucore"
  add_index "versions", ["version_number"], :name => "index_versions_on_number", :tablespace => "bc_nucore"
  add_index "versions", ["versioned_id", "versioned_type"], :name => "i_ver_ver_id_ver_typ", :tablespace => "bc_nucore"

  add_foreign_key "account_users", "accounts", :name => "fk_accounts"
  add_foreign_key "accounts", "facilities", :name => "fk_account_facility_id"
  add_foreign_key "bi_netids", "facilities", :name => "sys_c00260348"
  add_foreign_key "bundle_products", "products", :name => "fk_bundle_prod_bundle"
  add_foreign_key "bundle_products", "products", :name => "fk_bundle_prod_prod", :column => "bundle_product_id"
  add_foreign_key "facility_accounts", "facilities", :name => "fk_facilities"
  add_foreign_key "file_uploads", "order_details", :name => "fk_files_od"
  add_foreign_key "file_uploads", "products", :name => "fk_files_product"
  add_foreign_key "instrument_statuses", "products", :name => "fk_int_stats_product", :column => "instrument_id"
  add_foreign_key "order_details", "accounts", :name => "fk_od_accounts"
  add_foreign_key "order_details", "orders", :name => "sys_c009172"
  add_foreign_key "order_details", "price_policies", :name => "sys_c009175"
  add_foreign_key "order_details", "products", :name => "fk_bundle_prod_id", :column => "bundle_product_id"
  add_foreign_key "order_details", "products", :name => "sys_c009173"
  add_foreign_key "orders", "accounts", :name => "sys_c008808"
  add_foreign_key "orders", "facilities", :name => "orders_facility_id_fk"
  add_foreign_key "price_group_members", "price_groups", :name => "sys_c008583"
  add_foreign_key "price_groups", "facilities", :name => "sys_c008578"
  add_foreign_key "price_policies", "price_groups", :name => "sys_c008589"
<<<<<<< HEAD
=======

>>>>>>> upstream/shared_calendar
  add_foreign_key "product_users", "products", :name => "fk_products"
  add_foreign_key "products", "facilities", :name => "sys_c008556"
  add_foreign_key "products", "facility_accounts", :name => "fk_facility_accounts"
<<<<<<< HEAD
  add_foreign_key "reservations", "order_details", :name => "res_ord_det_id_fk"
  add_foreign_key "reservations", "products", :name => "reservations_instrument_id_fk", :column => "instrument_id"
  add_foreign_key "schedule_rules", "products", :name => "sys_c008573", :column => "instrument_id"
=======
  add_foreign_key "products", "schedules", :name => "fk_instruments_schedule"

  add_foreign_key "reservations", "order_details", :name => "res_ord_det_id_fk"
  add_foreign_key "reservations", "products", :name => "reservations_product_id_fk"

  add_foreign_key "schedule_rules", "products", :name => "sys_c008573", :column => "instrument_id"

  add_foreign_key "schedules", "facilities", :name => "fk_schedules_facility"

>>>>>>> upstream/shared_calendar
  add_foreign_key "statements", "facilities", :name => "fk_statement_facilities"
end
