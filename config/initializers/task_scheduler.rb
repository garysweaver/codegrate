require 'rubygems'
require 'rufus/scheduler'

unless ENV['NOINIT']
  # run at start
  RepositoryProcessor.delete_all_score_and_author_data
  
  # and schedule run
  scheduler = Rufus::Scheduler.start_new

  RepositoryProcessor.request_refresh_all

  scheduler.every '5s' do
     RepositoryProcessor.process_queue
  end

  scheduler.every '30m' do
     RepositoryProcessor.request_refresh_all
  end
end
