require "./lib_prolog"
require "./atom"

module Crolog
  class QueryIterator
    include Iterator(Atom)

    def initialize(@predicate : LibProlog::Predicate, @terms : LibProlog::Term)
      @query = LibProlog.open_query(nil, LibProlog::PL_Q_NORMAL, @predicate, @terms)
    end

    def next
      if LibProlog.next_solution(@query) == 0
        LibProlog.close_query(@query)
        stop
      else
        raise "unsupported term type" unless LibProlog.is_atom(@terms)
        Atom.new(@terms)
      end
    end
  end
end
