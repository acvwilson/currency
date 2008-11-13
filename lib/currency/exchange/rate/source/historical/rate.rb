require 'active_support'
require 'active_record/base'

require 'currency/exchange/rate/source/historical'

# This class represents a historical Rate in a database.
# It requires ActiveRecord.
#
class Currency::Exchange::Rate::Source::Historical::Rate < ::ActiveRecord::Base
   @@_table_name ||= Currency::Config.current.historical_table_name
   set_table_name @@_table_name

   # Can create a table and indices for this class
   # when passed a Migration.
   def self.__create_table(m, table_name = @@_table_name)
     table_name = table_name.intern 
     m.instance_eval do 
       create_table table_name do |t|
         t.column :created_on, :datetime, :null => false
         t.column :updated_on, :datetime
         
         t.column :c1,       :string,     :limit => 3, :null => false
         t.column :c2,       :string,     :limit => 3, :null => false
         
         t.column :source,   :string,     :limit => 32, :null => false
         
         t.column :rate,     :float,    :null => false
         
         t.column :rate_avg,      :float
         t.column :rate_samples,  :integer
         t.column :rate_lo,       :float
         t.column :rate_hi,       :float
         t.column :rate_date_0,   :float
         t.column :rate_date_1,   :float
         
         t.column :date,     :datetime, :null => false
         t.column :date_0,   :datetime
         t.column :date_1,   :datetime

         t.column :derived,  :string,   :limit => 64
       end
       
       add_index table_name, :c1
       add_index table_name, :c2
       add_index table_name, :source
       add_index table_name, :date
       add_index table_name, :date_0
       add_index table_name, :date_1
       add_index table_name, [:c1, :c2, :source, :date_0, :date_1], :name => 'c1_c2_src_date_range', :unique => true
     end
   end


   # Initializes this object from a Currency::Exchange::Rate object.
   def from_rate(rate)
     self.c1 = rate.c1.code.to_s
     self.c2 = rate.c2.code.to_s
     self.rate = rate.rate
     self.rate_avg = rate.rate_avg
     self.rate_samples = rate.rate_samples
     self.rate_lo  = rate.rate_lo
     self.rate_hi  = rate.rate_hi
     self.rate_date_0  = rate.rate_date_0
     self.rate_date_1  = rate.rate_date_1
     self.source = rate.source
     self.derived = rate.derived
     self.date = rate.date
     self.date_0 = rate.date_0
     self.date_1 = rate.date_1
     self
   end


   # Convert all dates to localtime.
   def dates_to_localtime!
     self.date   = self.date   && self.date.clone.localtime
     self.date_0 = self.date_0 && self.date_0.clone.localtime
     self.date_1 = self.date_1 && self.date_1.clone.localtime
   end


   # Creates a new Currency::Exchange::Rate object.
   def to_rate(cls = ::Currency::Exchange::Rate)
     cls.
       new(
           ::Currency::Currency.get(self.c1), 
           ::Currency::Currency.get(self.c2),
           self.rate,
           "historical #{self.source}",
           self.date,
           self.derived,
           {
             :rate_avg => self.rate_avg,
             :rate_samples => self.rate_samples,
             :rate_lo => self.rate_lo,
             :rate_hi => self.rate_hi,
             :rate_date_0 => self.rate_date_0,
             :rate_date_1 => self.rate_date_1,
             :date_0 => self.date_0,
             :date_1 => self.date_1
           })
   end


   # Various defaults.
   def before_validation
     self.rate_avg = self.rate unless self.rate_avg
     self.rate_samples = 1 unless self.rate_samples
     self.rate_lo = self.rate unless self.rate_lo
     self.rate_hi = self.rate unless self.rate_hi
     self.rate_date_0 = self.rate unless self.rate_date_0
     self.rate_date_1 = self.rate unless self.rate_date_1

     #self.date_0 = self.date unless self.date_0
     #self.date_1 = self.date unless self.date_1
     self.date = self.date_0 + (self.date_1 - self.date_0) * 0.5 if ! self.date && self.date_0 && self.date_1
     self.date = self.date_0 unless self.date
     self.date = self.date_1 unless self.date
   end


   # Returns a ActiveRecord::Base#find :conditions value
   # to locate any rates that will match this one.
   #
   # source may be a list of sources.
   # date will match inside date_0 ... date_1 or exactly.
   #
   def find_matching_this_conditions
     sql = [ ]
     values = [ ]

     if self.c1
       sql << 'c1 = ?'
       values.push(self.c1.to_s)
     end

     if self.c2
       sql << 'c2 = ?'
       values.push(self.c2.to_s)
     end

     if self.source
       if self.source.kind_of?(Array)
         sql << 'source IN ?'
       else
         sql << 'source = ?'
       end
       values.push(self.source)
     end

     if self.date
       sql << '(((date_0 IS NULL) OR (date_0 <= ?)) AND ((date_1 IS NULL) OR (date_1 > ?))) OR date = ?'
       values.push(self.date, self.date, self.date)
     end

     if self.date_0
       sql << 'date_0 = ?'
       values.push(self.date_0)
     end

     if self.date_1
       sql << 'date_1 = ?'
       values.push(self.date_1)
     end

     sql << '1 = 1' if sql.empty?

     values.unshift(sql.collect{|x| "(#{x})"}.join(' AND '))
     
     # $stderr.puts "values = #{values.inspect}"

     values
   end


   # Shorthand.
   def find_matching_this(opt1 = :all, *opts)
     self.class.find(opt1, :conditions => find_matching_this_conditions, *opts)
   end

 end # class


 
