require "./lib_prolog"

module Crolog
  class Atom
    @atom : LibProlog::Atom

    def initialize(term)
      LibProlog.get_atom(term, out @atom)
    end

    def string
      String.new(LibProlog.atom_chars(@atom))
    end

    def to_s(io)
      io << string
    end
  end
end
