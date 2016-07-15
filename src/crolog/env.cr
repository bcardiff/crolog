require "./lib_prolog"

module Crolog
  def self.load
    init_with_argv "#{__FILE__}", "--quiet"
  end

  def self.load(source)
    init_with_argv "#{__FILE__}", "-f", source, "--quiet"
  end

  def self.init_with_argv(*argv)
    LibProlog.initialise(argv.size, argv.to_a.map(&.to_unsafe))
  end

  def self.print_initialization
    argc = uninitialized LibProlog::CInt
    argv = uninitialized Pointer(Pointer(LibProlog::CChar))
    if LibProlog.is_initialised(out argc, out argv)
      puts "Crolog initialized"
      puts " arguments:"
      0.to argc - 1 do |i|
        puts "  #{String.new(argv[i])}"
      end
    end
  end
end
