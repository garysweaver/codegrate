require 'fileutils'
require 'grit'
require 'digest/md5'

include Grit

# thanks to https://gist.github.com/731502

class RepositoryProcessor

  @@processing = false
  @@repository_uri_refresh_queue = []
  
  def self.request_refresh_all
    Repository.all.each do |repository|
      RepositoryProcessor.request_refresh repository.uri
    end
  end
  
  def self.request_refresh(repository_uri)
    return unless repository_uri
    repo_sym = repository_uri.to_sym
    unless @@repository_uri_refresh_queue.include? repo_sym
      @@repository_uri_refresh_queue << repo_sym if Repository.find_by_uri(repository_uri)
    end
  end
  
  def self.delete_all_score_and_author_data
    Score.all.each do |s|
      Score.delete(s[:id])
    end
    
    Author.all.each do |a|
      Author.delete(a[:id])
    end
  end

  def self.process_queue
    # locking not perfect, but works for now.
    return if @@processing
    @@processing = true
    begin
      @@repository_uri_refresh_queue.each do |repo_sym|
        @@repository_uri_refresh_queue.delete repo_sym
        repository_uri = repo_sym.to_s
        repository = Repository.find_by_uri(repository_uri)
        process_repository(repository)
      end
    ensure
      @@processing = false
    end
  end
  
protected

  def self.process_repository(repository)
    return unless repository
    if repository.repository_type = 'git'
      process_git_repository(repository)
    else
      puts "Unsupported repository type: #{repository.repository_type}"
    end
  end

  def self.process_git_repository(repository)
    root_tmp = './repos'
    FileUtils.mkdir_p(root_tmp)
    fillin_tmp = File.join(root_tmp, 'fill-in')
    clone_tmp = File.join(root_tmp, Digest::MD5.hexdigest(repository.uri))
    puts "Cloning git repo '#{repository.name}' with URI: #{repository.uri} into #{clone_tmp}"
    begin
      FileUtils.rm_rf "#{clone_tmp}"
      if ENV['RCLONE']
        fillin_tmp_g = Grit::Git.new("#{fillin_tmp}")
        # if it takes more than a day to get the repo, something is incredibly wrong.
        Grit::Git.git_timeout = 24.hours
        fillin_tmp_g.clone({:quiet => false, :verbose => true, :progress => true, :branch => '24h'}, "#{repository.uri}", "#{clone_tmp}")
      else
        cmd = "git clone #{repository.uri} \"#{clone_tmp}\""
        puts cmd
        # TODO: consider other options: http://tech.natemurray.com/2007/03/ruby-shell-commands.html
        # can use exec cmd to debug/provide output.
        #exec cmd
        success = system cmd
        raise "clone failed! try exec '#{cmd}' for error info" if !success
      end
      
      g = Grit::Repo.new("#{clone_tmp}", {:is_bare => true})
    rescue Exception => e
      puts "*************************************************************************************"
      puts "Failed to clone repository: #{repository.uri}"
      puts "*************************************************************************************"
      puts "The following error may be difficult to diagnose. You probably just used the wrong uri."
      puts "Make sure it looks like: git://github.com/someuser/someproject.git or similar..."
      puts ""
      puts "#{e.inspect}"
      return
    end
    
    puts "Size of repo is: #{Dir.entries(clone_tmp).size}"
    
    puts "Analyzing Git repository..."
    days = Hash.new(0)
    #g.commits('master').each do |c|
    Grit::Git.git_timeout = 99999.hours
    g.log.each do |c|
      puts "author = '#{c.author.name}'"
      puts "email = '#{c.author.email}'"
      puts "date = '#{c.date}'"
      
      author = Author.find_or_create_by_email(c.author.email) { |a|
        a.name = c.author.name
      }
      
      commit_score = 0
      
      c.diffs.each do |d|
        puts d.inspect
        puts "#{d.diff}"
        if (d.diff)
          a = d.diff.scan(/\n\+/).size
          r = d.diff.scan(/\n\-/).size
          if r > a
            bonus = (r-a)
          else
            bonus = 0
          end      
          diff_score = a + r + bonus
          # double lines removed for those beyond the number of line additions
          diff_score = diff_score + (r-a) if r > a
          commit_score = commit_score + diff_score
          commit_score = 150 if commit_score > 150
          puts "LOC additions = #{a}"
          puts "LOC removals = #{r}"
          puts "LOC removals beyond additions = #{bonus}"
          puts "LOC score = #{diff_score}"
        end
      end
      
      Score.find_or_create_by_commit(c.sha) { |s|
        s.repository_id = repository[:id]
        s.author_id = author[:id]
        s.score = commit_score
        s.date = c.date
      }
      
    end
    
    puts ""
    puts "Repositories #{Repository.find(:all).inspect}"
    puts ""
    puts "Created Authors #{Author.find(:all).inspect}"
    puts ""
    puts "Created Scores #{Score.find(:all).inspect}"
    
    FileUtils.rm_rf(fillin_tmp)
    FileUtils.rm_rf(clone_tmp)
  end

end
