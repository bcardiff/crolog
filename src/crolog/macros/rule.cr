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

  LibProlog.cons_functor_v(models_arg0, pred, values)
  LibProlog.cons_functor(assert_terms, models_pred, models_arg0, models_arg1)

  {% else %}
  # rule is a fact
  LibProlog.cons_functor_v(assert_terms, pred, values)
  {% end %}

  query = LibProlog.open_query(nil, LibProlog::PL_Q_NORMAL, assert_predicate, assert_terms)
  LibProlog.next_solution(query)
  LibProlog.close_query(query)
end
