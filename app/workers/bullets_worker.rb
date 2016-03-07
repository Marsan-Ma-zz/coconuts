# encoding: utf-8
class BulletsWorker
  include Sidekiq::Worker
  #sidekiq_options queue: "high"  # change this shall add some config, else worker will not start. see document.
  # sidekiq_options retry: false

  def perform(local_path)
    sync_bullets(local_path)
  end

  private

  def sync_bullets(local_path)
    #puts "[1st run, create all bullets]"
    create_bullets(local_path)  # 1st run, create all bullets
    #puts "[2nd run, build related topics]"
    build_relations(local_path) # 2nd run, build related topics
  end

  def create_bullets(local_path)
    all_links = Bullet.only(:link).map(&:link)  # store links in RAM, saving SQL querying
    lines = []
    file = File.open(local_path)
    file.each do |line|
      lines << line
      if ((lines.count >= 1000) || file.eof?)
        posts = []
        lines.each do |line|
          line = JSON.parse(line)
          line['lang'] ||= "zh"
          if not (all_links.include?(line['link']) || line['summary'].empty? || (line['lang'] == "error"))
            #puts "[SAVE] #{line['title']}"
            posts << { :title => line['title'], :summary => line['summary'], :content => line['content'],
                        :link => line['link'], :source => line['src'], :thumbnail => line['thumb'], :lang => line['lang'],
                        :created_at => line['created_at'], :updated_at => line['updated_at'] }
          end
        end
        lines = []
        Bullet.create(posts)
      end
    end
  end

  def build_relations(local_path)
    all_links = Bullet.only(:link).map(&:link)  # store links in RAM, saving SQL querying
    File.open(local_path).each do |line|
      begin
        line = JSON.parse(line)
        if all_links.include?(line['link'])
          relates = JSON.parse(line['relate'])
          r_ids = Bullet.where(:link.in => relates.keys).only(:_id).map(&:_id)
          bul = Bullet.where(:link => line['link']).first
          bul.relate_ids = bul.relate_ids.concat(r_ids).uniq
          bul.save
        else
          #puts "[Error] #{line['link']} does not exist !"
        end
      rescue
        #puts "[Error] on #{line['link']}"
      end
    end        
  end

end
