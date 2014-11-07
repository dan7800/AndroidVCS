# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Remove 's' from table names
ActiveRecord::Base.pluralize_table_names = false

# Initialize the Rails application.
Rails.application.initialize!
