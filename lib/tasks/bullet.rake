#encoding: utf-8  

namespace :bullet do
  task :score_curate => :environment do
    Bullet.desc(:created_at).limit(5000).in_groups_of(500) do |g|
      #p "processing 500..."
      batch_get_curate_count(g)
    end
  end

  def batch_get_curate_count(bullets)
    query = []
    bullets.map{|i| query.append(i.link.split('?')[0])}
    fql = Fql.execute(
      'SELECT like_count, share_count, comment_count, total_count from link_stat where url IN ' + "(#{query.to_s[1..-2]})"
    )
    for i in 0..fql.size-1
      bullets[i].update_attributes(
        :like_count => fql[i]['like_count'],
        :share_count => fql[i]['share_count'],
        :comment_count => fql[i]['comment_count'],
        :curate_score => 2*fql[i]['comment_count'] + 2*fql[i]['share_count'] + fql[i]['like_count']
      )
    end
  end
end
