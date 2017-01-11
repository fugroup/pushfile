require './config/boot'

include Futest::Helpers

@host = "http://localhost:4001"

# Load tests. Comment out the ones you don't want to run.
begin
  start = Time.now
  [
    'upload'
  ].each{|t| require_relative "#{t}_test"}
rescue => x
  puts x.message
  err(x)
ensure
  puts Time.now - start
end