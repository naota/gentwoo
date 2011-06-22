xml.instruct!
 
xml.rss("version"    => "2.0",
        "xmlns:dc"   => "http://purl.org/dc/elements/1.1/",
        "xmlns:atom" => "http://www.w3.org/2005/Atom") do
  xml.channel do
    xml.title       @site_title
    xml.link        @site_url
    xml.pubDate     Time.now.rfc822
    xml.description @site_description
    xml.atom :link, "href" => @rss_url, "rel" => "self", "type" => "application/rss+xml"
 
    @entries.each do |entry|
      xml.item do
        xml.title        "@"+entry.user.login+"のコメント"
        xml.link         "http://gentwoo.elisp.net"+emerge_path(entry.commentable)
        xml.guid         "http://gentwoo.elisp.net"+emerge_path(entry.commentable)
        xml.description  entry.commentable.fullname+": "+entry.content
        xml.pubDate      entry.created_at.to_formatted_s(:rfc822)
        xml.dc :creator, @author
      end
    end
  end
end
