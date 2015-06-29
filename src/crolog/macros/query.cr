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
