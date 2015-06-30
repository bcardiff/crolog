@[Link("swipl")]
lib LibProlog
  type Module = Void*
  type Predicate = Void*
  type Atom = UInt8*
  type Term = UInt8*
  type Functor = UInt8*

  type Query = UInt8*

  alias CInt = Int32
  alias CChar = UInt8

  alias PLFunction = Void*

  PL_Q_NORMAL = 0x02  # normal usage
  PL_Q_NODEBUG = 0x04  # use this one
  PL_Q_CATCH_EXCEPTION = 0x08  # handle exceptions in C
  PL_Q_PASS_EXCEPTION = 0x10  # pass to parent environment

  PL_FA_NOTRACE = 0x01 # foreign cannot be traced
  PL_FA_TRANSPARENT = 0x02 # foreign is module transparent
  PL_FA_NONDETERMINISTIC = 0x04 # foreign is non-deterministic
  PL_FA_VARARGS = 0x08 # call using t0, ac, ctx
  PL_FA_CREF = 0x10 # Internal: has clause-reference
  PL_FA_ISO = 0x20 # Internal: ISO core predicate

  PL_ATOM = 2
  PL_INTEGER = 3

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
  fun put_term = PL_put_term(Term, Term) : CInt
  fun put_int64 = PL_put_int64(Term, Int64) : CInt
  # fun put_functor = PL_put_functor(Term, Functor) : CInt

  fun get_atom = PL_get_atom(Term, Atom*) : CInt
  fun get_integer = PL_get_integer(Term, CInt*): CInt

  fun term_type = PL_term_type(Term) : CInt

  fun is_atom = PL_is_atom(Term) : CInt
  fun is_variable = PL_is_variable(Term) : CInt
  fun is_integer = PL_is_integer(Term) : CInt

  fun unify_integer = PL_unify_integer(Term, CInt) : CInt


  fun register_foreign = PL_register_foreign(name : CChar*, arity : CInt, f : PLFunction, flags : CInt) : CInt

end
