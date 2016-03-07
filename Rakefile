require 'rubygems'
require 'bundler/setup'

require 'rake'

#############################################################################
#
# Standard tasks
#
#############################################################################

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'test'
  test.pattern = 'test/test_*.rb'
  test.verbose = true
end
