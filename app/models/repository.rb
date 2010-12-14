class Repository < ActiveRecord::Base
  
  SUPPORTED_REPOSITORY_TYPES = ['git']
  
  after_save :request_refresh
  
  def request_refresh
    RepositoryProcessor.request_refresh(self.uri)
  end
end
