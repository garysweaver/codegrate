class Repository < ActiveRecord::Base
  
  SUPPORTED_REPOSITORY_TYPES = ['git']
  
  after_save :process
  
  def process
    RepositoryProcessor.process_repository(self)
  end
end
