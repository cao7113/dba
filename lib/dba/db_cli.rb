class DbCli
  def self.pgcli(url)
    pgcli = 'pgcli'
    pgcli = 'psql' if ENV['psql']
    cmd = "#{pgcli} #{url}"
    puts "==run: #{cmd}"
    system cmd
  end
end
