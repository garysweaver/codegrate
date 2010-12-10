require 'fileutils'
require 'grit'

include Grit

# thanks to https://gist.github.com/731502

class RepositoryProcessor

  @@processing = false
  
  def self.process
    # not a perfect lock, but works for now
    if @@processing
      puts "call to process all repositories ignored. still waiting on previous job to complete"
      return
    end 
    @@processing = true
    begin
      process_repositories
    ensure
      @@processing = false
    end
  end

  def self.process_repositories
    puts "Processing repositories..."
    Score.all.each do |s|
      Score.delete(s.object_id)
    end
    
    Author.all.each do |a|
      Author.delete(a.object_id)
    end
    
    Repository.all.each do |repository|
      process_repository(repository)
    end
  end
  
  def self.process_repository(repository)
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
    clone_tmp = File.join(root_tmp, repository.name.underscore)
    puts "Cloning git repo '#{repository.name}' with URI: #{repository.uri} into #{clone_tmp}"
    
    begin
      fillin_tmp_g = Grit::Git.new("#{fillin_tmp}")
      fillin_tmp_g.clone({:quiet => false, :verbose => true, :progress => true, :branch => '37s'}, "#{repository.uri}", "#{clone_tmp}")
      g = Grit::Repo.new("#{clone_tmp}", {:is_bare => true})
    rescue Exception => e
      puts "*************************************************************************************"
      puts "Failed to clone repository: #{r.uri}"
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
    g.commits('master').each do |c|
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
          diff_score = a + r
          commit_score = commit_score + diff_score
          puts "LOC additions= #{a}"
          puts "LOC removals= #{r}"
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
