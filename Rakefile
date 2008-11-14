# Rakefile for currency      -*- ruby -*-
# Adapted from RubyGems/Rakefile

# For release
"
rake make_manifest
rake update_version
svn status
rake package
rake release VERSION=x.x.x
rake svn_release
rake publish_docs
rake announce
"

#################################################################

require 'rubygems'

#################################################################
# Release notes
#

def get_release_notes(relfile = "Releases.txt")

  release = nil
  notes = [ ]

  File.open(relfile) do |f|
    while ! f.eof && line = f.readline
      if md = /^== Release ([\d\.]+)/i.match(line)
        release = md[1]
        notes << line
        break
      end
    end

    while ! f.eof && line = f.readline
      if md = /^== Release ([\d\.]+)/i.match(line)
        break
      end
      notes << line
    end
  end

  [ release, notes.join('') ]
end

#################################################################

release, release_notes = get_release_notes

#################################################################

# Misc Tasks ---------------------------------------------------------

def egrep(pattern)
  Dir['**/*.rb'].each do |fn|
    count = 0
    open(fn) do |f|
      while line = f.gets
      	count += 1
      	if line =~ pattern
      	  puts "#{fn}:#{count}:#{line}"
      	end
      end
    end
  end
end

desc "Look for TODO and FIXME tags in the code"
task :todo do
  egrep /#.*(FIXME|TODO|TBD)/
end

desc "Look for Debugging print lines"
task :dbg do
  egrep /\bDBG|\bbreakpoint\b/
end

desc "List all ruby files"
task :rubyfiles do 
  puts Dir['**/*.rb'].reject { |fn| fn =~ /^pkg/ }
  puts Dir['bin/*'].reject { |fn| fn =~ /CVS|.svn|(~$)|(\.rb$)/ }
end

task :make_manifest do 
  open("Manifest.txt", "w") do |f|
    f.puts Dir['**/*'].reject { |fn| 
      fn == 'email.txt' ||
      ! test(?f, fn) || 
      fn =~ /CVS|.svn|([#~]$)|(.gem$)|(^pkg\/)|(^doc\/)/ 
    }.sort.join("\n") + "\n"
  end
end
