#!/usr/bin/ruby

require 'rubygems'
require 'pp'

USER_NUM = 1000
PACKAGE_NAME_NUM = 5000
PACKAGE_VERSION_NUM = 20
EMERGE_NUM = 600*400*10
TIME_RANGE = 3600*24*365*2.0

TEXT_CHARS = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-_,."

def text_data(col,short=nil)
  len = if short then short+rand(col) else col end
  ret = []
  len.times do |i|
      ret << TEXT_CHARS[rand(TEXT_CHARS.size)]
  end
  return ret.pack('C*')
end

$curtime = Time.now.to_f

def time_data
  return Time.at($curtime - TIME_RANGE * rand)
end

def power_choose(ar)
  len = ar.size
  i = (Math.exp(-4*rand)*len).to_i
  return ar[i]
end

class User
  @@id_gen = 1
  def initialize
    @id = @@id_gen
    @@id_gen += 1
    @login = text_data(20)
  end
  attr :id
  def to_sql
    "INSERT INTO users (id,twitter_id,login) VALUES (#{@id},'#{@login}','#{@login}');"
  end
end

class Package
  @@id_gen = 1
  def initialize(category,name,version)
    @id = @@id_gen
    @@id_gen += 1
    @category = category
    @name = name
    @version = version
  end
  attr :id
  def to_sql
    "INSERT INTO packages (id,category,name,version) VALUES (#{@id},'#{@category}','#{@name}','#{@version}');"
  end
end


class Emerge 
  @@id_gen = 1
  def initialize(package, user)
    @id = @@id_gen
    @@id_gen += 1
    @duration = if (rand > 0.05) then rand(300) else 0 end
    @user_id = user.id
    @package_id = package.id
    @buildtime = time_data.strftime("%Y-%m-%d %H:%M:%S")
  end
  def to_sql
    "INSERT INTO emerges (id,buildtime,duration,package_id,user_id,log,errorlog) VALUES (#{@id},'#{@buildtime.to_s}',#{@duration},#{@package_id},#{@user_id},'#{@log}','#{@errorlog}');"
  end
end

def init_data
  output = open('test_data.sql','w')
  output.puts '
PRAGMA synchronous=OFF;
PRAGMA count_changes=OFF;
PRAGMA journal_mode=MEMORY;
PRAGMA temp_store=MEMORY;
BEGIN TRANSACTION;
'
  $users = []
  USER_NUM.times do |i|
    $users << User.new
  end
  $users.sort_by{rand}
  puts "users: #{$users.size}"

  $users.each do |i|
    output.puts i.to_sql
  end

  categories = []
  100.times {
    categories << text_data(10,5)
  }

  $packages = []
  PACKAGE_NAME_NUM.times do |i|
    cat = categories[rand(categories.size)]
    package_name = text_data(60,20)
    PACKAGE_VERSION_NUM.times do |j|
      version_num = text_data(5,10)
      $packages << Package.new(cat,package_name,version_num)
    end
  end
  $packages.sort_by{rand}
  puts "packages: #{$packages.size}"

  $packages.each do |i|
    output.puts i.to_sql
  end

  EMERGE_NUM.times do |i|
    e = Emerge.new(power_choose($packages),
                   power_choose($users))
    output.puts e.to_sql
    puts "emerges... : #{i+1}/#{EMERGE_NUM}" if (i % 5000) == 0
  end
  puts "emerges: #{EMERGE_NUM}"

  output.puts 'COMMIT TRANSACTION;'
  output.flush
  output.close
end

init_data

