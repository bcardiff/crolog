@[Link(ldflags: "-L/usr/local/Cellar/swi-prolog/7.2.0/libexec/lib/swipl-7.2.0/lib/x86_64-darwin13.4.0 -lswipl")]
lib LibProlog
  type Module = Void*
  type Predicate = Void*
  type Atom = UInt8*
  type Term = UInt8*
  type Functor = UInt8*

  type Query = UInt8*

  alias CInt = Int32
  alias CChar = UInt8

  PL_Q_NORMAL = 0x02  # normal usage
  PL_Q_NODEBUG = 0x04  # use this one
  PL_Q_CATCH_EXCEPTION = 0x08  # handle exceptions in C
  PL_Q_PASS_EXCEPTION = 0x10  # pass to parent environment

  fun initialise = PL_initialise(CInt, CChar**) : CInt
  fun is_initialised = PL_is_initialised(CInt*, CChar***) : CInt
  fun top_level = PL_toplevel() : CInt

  fun context = PL_context() : Module
  fun module_name = PL_module_name(Module) : Atom
  fun new_module = PL_new_module(Atom) : Module

  fun open_query = PL_open_query(Module, CInt, Predicate, Term) : Query
  fun next_solution = PL_next_solution(Query) : CInt
  fun close_query = PL_close_query(Query)

  fun atom_chars = PL_atom_chars(Atom) : CChar*

  fun predicate = PL_predicate(name : CChar*, arity : CInt, module_name : CChar*) : Predicate
  fun predicate_info = PL_predicate_info(Predicate, Atom*, arity : CInt*, mod : Module*) : CInt

  fun new_term_refs = PL_new_term_refs(CInt) : Term
  fun new_term_ref = PL_new_term_ref() : Term
  # PL_EXPORT(term_t) PL_copy_term_ref(term_t from);
  # PL_EXPORT(void)   PL_reset_term_refs(term_t r);

  fun new_atom = PL_new_atom(CChar*) : Atom

  fun new_functor = PL_new_functor(Atom, arity : CInt) : Functor
  fun cons_functor = PL_cons_functor(Term, Functor, ...) : CInt
  fun cons_functor_v = PL_cons_functor_v(Term, Functor, Term) : CInt

  # PL_EXPORT(atom_t) PL_functor_name(functor_t f);
  # PL_EXPORT(int)    PL_functor_arity(functor_t f);


  fun put_atom_chars = PL_put_atom_chars(Term, CChar*) : CInt
  # fun put_term = PL_put_term(Term, Term) : CInt
  # fun put_functor = PL_put_functor(Term, Functor) : CInt

  fun get_atom = PL_get_atom(Term, Atom*) : CInt

  fun is_atom = PL_is_atom(Term) : CInt
  fun is_variable = PL_is_variable(Term) : CInt
end

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
    argc :: LibProlog::CInt
    argv :: Pointer(Pointer(LibProlog::CChar))
    if LibProlog.is_initialised(out argc, out argv)
      puts "Crolog initialized"
      puts " arguments:"
      0.to argc-1 do |i|
        puts "  #{String.new(argv[i])}"
      end
    end
  end

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

  class Atom
    @atom :: LibProlog::Atom

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

macro query(expr)
  predicate = LibProlog.predicate({{expr.name.stringify}}, {{expr.args.length}}, nil)
  terms = LibProlog.new_term_refs({{expr.args.length}})
  {% for arg, index in expr.args %}
    {{"p#{index}".id}} = term_n(terms, {{index}})
    {% if arg.is_a?(Call) %}
      # {{"p#{index}".id}} is a var due to new_term_refs
    {% end %}
    {% if arg.is_a?(SymbolLiteral) %}
      LibProlog.put_atom_chars({{"p#{index}".id}}, {{arg.stringify[1..-1]}})
    {% end %}
  {% end %}

  Crolog::QueryIterator.new(predicate, terms).each do
    {% for arg, index in expr.args %}
      {% if arg.is_a?(Call) %}
        # TODO check if the result is an atom
        {{arg.name}} = Crolog::Atom.new({{"p#{index}".id}})
      {% end %}
    {% end %}

    {{ expr.block.body }}
  end
end

macro translate_clause_to(dest, clause)
  {% arg = clause.args.first %}
  LibProlog.cons_functor(models_arg0, pred, {{"var_#{arg.name}".id}})
  pred_body = LibProlog.new_functor(LibProlog.new_atom({{clause.name.stringify}}), 1)
  LibProlog.cons_functor({{dest}}, pred_body, {{"var_#{arg.name}".id}})
end

macro term_n(term, n)
  ((({{term}} as UInt8*) + {{n}}) as LibProlog::Term)
end

macro rule(expr)
  assert_predicate = LibProlog.predicate("assert", 1, nil)
  assert_terms = LibProlog.new_term_refs(1)

  pred = LibProlog.new_functor(LibProlog.new_atom({{expr.name.stringify}}), {{expr.args.length}});
  values = LibProlog.new_term_refs({{expr.args.length}})

  {% for arg, index in expr.args %}
    {% if arg.is_a?(Call) %}
      {{"var_#{arg.name}".id}} = term_n(values, {{index}})
    {% end %}
    {% if arg.is_a?(SymbolLiteral) %}
      LibProlog.put_atom_chars(term_n(values, {{index}}), {{arg.stringify[1..-1]}})
    {% end %}
  {% end %}


  {% if expr.block %}
  models_pred = LibProlog.new_functor(LibProlog.new_atom(":-"), 2);
  models_args = LibProlog.new_term_refs(2)

  models_arg0 = term_n(models_args, 0)
  models_arg1 = term_n(models_args, 1)

  {% if expr.block.body.is_a?(Expressions) %}
    clauses_terms = LibProlog.new_term_refs(2)
    first_clause_term = clauses_terms

    clauses :: LibProlog::Term
    new_clause :: LibProlog::Term
    # multi clause block
    {% for e, index in expr.block.body.expressions %}
      {% if index == 0 %}
        translate_clause_to(clauses_terms, {{e}})
      {% else %}
        second_clause_term = term_n(clauses_terms, 1)
        translate_clause_to(second_clause_term, {{e}})

        tuple_functor = LibProlog.new_functor(LibProlog.new_atom(","), 2);

        {% if index < expr.block.body.expressions.length - 1 %}
          old_clauses_terms = clauses_terms
          clauses_terms = LibProlog.new_term_refs(2)
          first_clause_term = clauses_terms
          LibProlog.cons_functor(first_clause_term, tuple_functor, old_clauses_terms, second_clause_term)
        {% end %}
      {% end %}
    {% end %}

    LibProlog.cons_functor(models_arg1, tuple_functor, first_clause_term, second_clause_term)
  {% end %}

  {% if expr.block.body.is_a?(Call) %}
    # single clause block
    translate_clause_to(models_arg1, {{expr.block.body}})
  {% end %}

  LibProlog.cons_functor(models_arg0, pred, {{"var_#{expr.args.first.name}".id}})
  LibProlog.cons_functor(assert_terms, models_pred, models_arg0, models_arg1)


  {% else %}
  # rule is a fact
  LibProlog.cons_functor_v(assert_terms, pred, values)
  {% end %}

  query = LibProlog.open_query(nil, LibProlog::PL_Q_NORMAL, assert_predicate, assert_terms)
  LibProlog.next_solution(query)
  LibProlog.close_query(query)
end
