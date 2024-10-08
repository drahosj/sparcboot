require 'yaml'
require 'json'

config = YAML.load_file 'build.yaml'

builddir = config['builddir']
workdir = File.join builddir, 'work'
libs = config['libs']

#searchpath = libs.keys.map{|k| File.join builddir, k}
searchpath = [workdir]

searchpath.each{|d| `mkdir -p #{d}`}

ghdl_searchpath = searchpath.map{|p| "-P#{p}"}
ghdl_import_args = [
  '--mb-comments',
]
ghdl_import_args += ghdl_searchpath
ghdl_import_args << "--workdir=#{workdir}"

ghdl_make_args = [
  '-fexplicit',
  '--ieee=synopsys',
  '--mb-comments',
  '--warn-no-binding',
  '--warn-no-hide',
  '-O2',
]
ghdl_make_args << "--workdir=#{workdir}"
ghdl_make_args += ghdl_searchpath

ghdl_run_args = [
  '--ieee=synopsys',
]
ghdl_run_args += ghdl_searchpath
ghdl_run_args << "--workdir=#{workdir}"

def runcmd(cmd)
  puts cmd
  `#{cmd}`
  raise "Build failed" if $? != 0
end

if ARGV[0] == 'build'
  libs.each_pair do |name, lib|
    #workdir = File.join builddir, name
    work = name

    files = []
    if lib.class != Array
      lib = [lib]
    end

    lib.each do |lib|
      p lib
      path = lib['path']
      prefix = lib['prefix']
      
      path = File.join(ENV[prefix], path) if prefix
      path = './' if path.nil?
      
      libfiles = lib['files']
      libfiles = [] if libfiles.nil?

      files += libfiles.map{|f| File.join path, f}
    end

    args = ghdl_import_args.clone
    args << "--work=#{work}"
    files.each do |f|
      runcmd("ghdl -i #{args.join(' ')} #{f}")
    end
  end

  runcmd("ghdl -m #{ghdl_make_args.join(' ')} testbench")
end

if ARGV[0] == 'run'
  exec("ghdl -r #{ghdl_run_args.join(' ')} testbench")
end

puts ARGV[0]
