#!/usr/bin/env ruby
# quick docker test powered by ruby

#tdb = "postgres://postgres@docker.for.mac.host.internal/lstarup0"
tdb = "postgres://postgres@docker.for.mac.host.internal/cao9_development"
$tmpdir = Pathname.pwd.join('tmp/docker') 

def dktmp_file_for(str)
  tmpfile = $tmpdir.join("#{Time.now.to_i.to_s}.sh")
  tmpfile.write str
  tmpfile.chmod(0755)
  tmpfile
end

tfile = dktmp_file_for <<-Sh
#!/usr/bin/env sh
pga dump #{tdb} 
sh # wait your command
Sh
rfile = tfile.relative_path_from($tmpdir)

dockimg = 'dba:pg96'
system "docker build -t #{dockimg} ."
system "docker run -v #{$tmpdir.to_s}:/dktmp -w /dktmp --rm -it #{dockimg} ./#{rfile}"

puts '==finish'
