macro translate_clause_to(dest, clause)
  %values = LibProlog.new_term_refs({{clause.args.length}})
  {% for arg, index in clause.args %}
    {% if arg.is_a?(Call) %}
      LibProlog.put_term(term_n(%values, {{index}}), {{"var_#{arg.name}".id}})
    {% elsif arg.is_a?(SymbolLiteral) %}
      LibProlog.put_atom_chars(term_n(%values, {{index}}), {{arg.stringify[1..-1]}})
    {% elsif arg.is_a?(NumberLiteral) %}
      LibProlog.put_int64(term_n(%values, {{index}}), {{arg}}.to_i64)
    {% else %}
      {{ raise "not implemented" }}
    {% end %}

  {% end %}

  %pred_body = LibProlog.new_functor(LibProlog.new_atom({{clause.name.stringify}}), {{clause.args.length}})
  LibProlog.cons_functor_v({{dest}}, %pred_body, %values)
end

macro term_n(term, n)
  ((({{term}} as UInt8*) + {{n}}) as LibProlog::Term)
end
