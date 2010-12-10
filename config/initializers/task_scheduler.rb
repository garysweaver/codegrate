require 'rubygems'
require 'rufus/scheduler'

unless ENV['NOINIT']
  # run at start
  RepositoryProcessor.process

  # and schedule run
  scheduler = Rufus::Scheduler.start_new

  scheduler.every '5m' do
     RepositoryProcessor.process
  end
end
