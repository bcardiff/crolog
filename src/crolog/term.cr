module Crolog
  struct Term
    def initialize(@inner : LibProlog::Term)
    end

    def unify(value : Int32)
      LibProlog.unify_integer(@inner, value)
    end

    def int
      raise "term is not integer" unless LibProlog.is_integer(@inner)
      LibProlog.get_integer(@inner, out res)
      res
    end
  end
end
