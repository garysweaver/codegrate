require 'rubygems'
require 'rufus/scheduler'

unless ENV['NOINIT']
  # run at start
  spawn do
    RepositoryProcessor.process
  end
  
  # and schedule run
  scheduler = Rufus::Scheduler.start_new

  scheduler.every '30m' do
     RepositoryProcessor.process
  end
end
