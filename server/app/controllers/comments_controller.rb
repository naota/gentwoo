# -*- coding: utf-8 -*-
class CommentsController < ApplicationController
  before_filter :login_required, :only => [:create]

  def create
    @emerge = Emerge.find(params[:emerge_id])
    params[:comment][:user_id] = current_user.id
    @comment = @emerge.comments.create(params[:comment])
    
    if current_user.tweet_comment
      head = "Comment added: @"+@emerge.user.login+" "+@emerge.fullname
      body = @comment.content
      foot = "http://gentwoo.elisp.net"+emerge_path(@emerge)+" #GenTwoo"

      headlen = head.split(//u).length
      bodylen = body.split(//u).length
      footlen = foot.split(//u).length
      current_user.twitter.post('/statuses/update.json', :status => 
                                if headlen + bodylen + footlen <= 137
                                  head + "\"" + body + "\"" + foot
                                elsif headlen + footlen > 140
                                  "Comment added: @"+@emerge.user.login+
                                    "http://gentwoo.elisp.net"+emerge_path(@emerge)
                                elsif headlen + footlen > 136
                                  head + body
                                else
                                  head + "\"" + 
                                    body.split(//u)[0,136-headlen-footlen].join('') +
                                    "…\"" + foot
                                end )
    end

    redirect_to emerge_path(@emerge)
  end

  def index
    @site_title = "GenTwoo"
    @site_url = "http://gentwoo.elisp.net/"
    @site_description = "Social Compiling Site - GenTwoo"
    @rss_url = "http://gentwoo.elisp.net/comments.rss"
    @author = "GenTwoo"

    @entries = Comment.order("created_at DESC").limit(20)

    respond_to do |type|
#      type.html
      type.rss
#      type.atom
    end
  end
end
