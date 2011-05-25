# -*- coding: utf-8 -*-
class CommentsController < ApplicationController
  before_filter :login_required, :only => [:create]

  def create
    @emerge = Emerge.find(params[:emerge_id])
    params[:comment][:user_id] = current_user.id
    @comment = @emerge.comments.create(params[:comment])
    
    if current_user.tweet_comment
      head = "@"+@emerge.user.login+" さんの"+@emerge.fullname+"に"
      body = @comment.content
      foot = "コメントしました。 "+"http://gentwoo.elisp.net"+emerge_path(@emerge)+" #GenTwoo"

      headlen = head.split(//u).length
      bodylen = body.split(//u).length
      footlen = foot.split(//u).length
      current_user.twitter.post('/statuses/update.json', :status => 
                                if headlen + bodylen + footlen <= 137
                                  head + "「" + body + "」と" + foot
                                elsif headlen + footlen > 140
                                  "@"+@emerge.user.login+" さんにコメントしました。 "+
                                    "http://gentwoo.elisp.net"+emerge_path(@emerge)
                                elsif headlen + footlen > 136
                                  head + body
                                else
                                  head + "「" + 
                                    body.split(//u)[0,136-headlen-footlen].join('') +
                                    "…」と" + foot
                                end )
    end

    redirect_to emerge_path(@emerge)
  end
end
