#!/usr/bin/env ruby
# quick docker test powered by ruby

dbsfile = Pathname("~/.dbs.yml").expand_path
$tmpdir = Pathname.pwd.join('tmp/docker')
$tmpdir.mkpath

def dktmp_file_for(str)
  tmpfile = $tmpdir.join("#{Time.now.to_i.to_s}.sh")
  tmpfile.write str
  tmpfile.chmod(0755)
  tmpfile
end

tfile = dktmp_file_for <<-Sh
#!/usr/bin/env sh
export DBSFILE=/dbs.yml
pga dump docker_test
export PS1=docker:$PS1
echo ==You are in container shell
sh # wait your command
Sh
rfile = tfile.relative_path_from($tmpdir)

dockimg = 'dba:pg96'
system "docker build -t #{dockimg} ."
system "docker run -v #{$tmpdir.to_s}:/dktmp -v #{dbsfile}:/dbs.yml -w /dktmp --rm -it #{dockimg} ./#{rfile}"
tfile.delete

puts '==finish'
