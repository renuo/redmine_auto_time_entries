require_relative 'lib/assigner'
require_relative 'lib/splitter'
require_relative 'lib/redmine_adapter'

s = Splitter.new
s.split_time_entries
