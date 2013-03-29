require 'pathname'

shared_path = File.join(Pathname.new(File.dirname(__FILE__)).realpath, '../../../shared')

listen '0.0.0.0:9000'
worker_processes 4 # this should be >= nr_cpus
pid "#{shared_path}/pids/unicorn.pid"
stderr_path "#{shared_path}/log/unicorn.err.log"
stdout_path "#{shared_path}/log/unicorn.out.log"

preload_app true
timeout 180

before_fork do |server, worker|
  ActiveRecord::Base.connection.disconnect!

  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  ActiveRecord::Base.establish_connection
end
