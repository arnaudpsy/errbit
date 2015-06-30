namespace :sync do

  desc <<-DESC
    Synchronizes local database with production
    bundle exec rake sync:local['production, local']
    bundle exec rake sync:local['heroku_mdr0bmdm, errbit_tonpsy_fork_development']
  DESC
  task :local, :production, :local do |t, args|
    args.each { |k, v| puts "#{k} => #{v}" }
    cmd = "mongorestore -v -h localhost " \
      "--port 27017 " \
      "--db #{args.local} " \
      "--drop tmp/#{Time.now.strftime('%Y%m%d')}/#{args.production}"
    puts cmd
    system cmd
  end

  desc <<-DESC
    bundle exec rake sync:backup['database, user, password, url']
    bundle exec rake sync:backup['heroku_mdr0bmdm, heroku_mdr0bmdm, 4vfe7nr6gpdgb15ji88lgma8u, ds061391.mongolab.com:61391']
    heroku run rake "sync:backup['database, user, password, url']"
  DESC
  task :backup, :database, :user, :password, :url do |t, args|
    args.each { |k, v| puts "#{k} => #{v}" }
    cmd = "mongodump -h #{args.url} " \
      "-d #{args.database} " \
      "-u #{args.user} " \
      "-p #{args.password} " \
      "-o tmp/#{Time.now.strftime('%Y%m%d')}"
    puts cmd
    system cmd
  end

  desc <<-DESC
    bundle exec rake sync:user['joel@tonpsy.com']
  DESC
  task :user, :email do |t, args|
    args.each { |k, v| puts "#{k} => #{v}" }
    Rake::Task[:environment].invoke
    user = User.where({email: args.email}).first
    user.password = 'secret'
    user.password_confirmation = 'secret'
    user.save
    puts "#{args.email} account updated"
  end

end
