module Dba::DbCli
  def self.exec(url, runner: nil)
    runner ||= env_runner
    cmd = "#{runner} #{url}"
    puts "==run: #{cmd}"
    system cmd
  end

  # support: psql, pgcli, sequel...
  def self.env_runner
    ENV['SQL_RUNNER'] || ENV['sql_runner']
  end
end
