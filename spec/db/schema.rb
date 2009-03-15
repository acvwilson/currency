ActiveRecord::Schema.define(:version => 0) do
  create_table :dogs, :force => true do |t|
    t.column :name, :string
    t.column :price, :integer, :limit => 8
    t.column :price_currency, :string, :limit => 5
  end
  
  create_table :currency_codes, :force => true do |t|
    t.string   :code,       :limit => 5
    t.string   :name
    t.datetime :created_at
    t.datetime :updated_at
  end

  add_index :currency_codes, ["code"], :name => "index_currency_codes_on_code", :unique => true

  create_table :currency_historical_rates, :force => true do |t|
    t.datetime :created_on,                 :null => false
    t.datetime :updated_on
    t.string   :c1,           :limit => 3,  :null => false
    t.string   :c2,           :limit => 3,  :null => false
    t.string   :source,       :limit => 32, :null => false
    t.float    :rate,                       :null => false
    t.float    :rate_avg
    t.integer  :rate_samples
    t.float    :rate_lo
    t.float    :rate_hi
    t.float    :rate_date_0
    t.float    :rate_date_1
    t.datetime :date,                       :null => false
    t.datetime :date_0
    t.datetime :date_1
    t.string   :derived,      :limit => 64
  end

  add_index :currency_historical_rates, ["c1", "c2", "source", "date_0", "date_1"], :name => :c1_c2_src_date_range, :unique => true
  add_index :currency_historical_rates, ["c1"], :name => :index_currency_historical_rates_on_c1
  add_index :currency_historical_rates, ["c2"], :name => :index_currency_historical_rates_on_c2
  add_index :currency_historical_rates, ["date"], :name => :index_currency_historical_rates_on_date
  add_index :currency_historical_rates, ["date_0"], :name => :index_currency_historical_rates_on_date_0
  add_index :currency_historical_rates, ["date_1"], :name => :index_currency_historical_rates_on_date_1
  add_index :currency_historical_rates, ["source"], :name => :index_currency_historical_rates_on_source
  
end