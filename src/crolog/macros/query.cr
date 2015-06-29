macro query(expr)
  predicate = LibProlog.predicate({{expr.name.stringify}}, {{expr.args.length}}, nil)
  terms = LibProlog.new_term_refs({{expr.args.length}})
  {% for arg, index in expr.args %}
    {{"p#{index}".id}} = term_n(terms, {{index}})
    {% if arg.is_a?(Cast) %}
      {% arg = arg.obj %}
    {% end %}

    {% if arg.is_a?(Call) || arg.is_a?(Var) %}
      # {{"p#{index}".id}} is a var due to new_term_refs
    {% elsif arg.is_a?(SymbolLiteral) %}
      LibProlog.put_atom_chars({{"p#{index}".id}}, {{arg.stringify[1..-1]}})
    {% elsif arg.is_a?(NumberLiteral) %}
      LibProlog.put_int64({{"p#{index}".id}}, {{arg}}.to_i64)
    {% else %}
      {{ puts arg.is_a?(Call) }}
      {{ raise "not implemented" }}
    {% end %}
  {% end %}

  Crolog::QueryIterator.new(predicate, terms).each do
    {% for arg, index in expr.args %}
      {% if arg.is_a?(Cast) %}
        {% result_type = arg.to.stringify %}
        {% arg = arg.obj %}
      {% else %}
        {% result_type = "Crolog::Atom" %}
      {% end %}

      {% if arg.is_a?(Call) || arg.is_a?(Var) %}
        {% if arg.is_a?(Call) %}
          {% var_name = arg.name %}
        {% elsif arg.is_a?(Var) %}
          {% var_name = arg.stringify %}
        {% else %}
          {{ raise "not implemented" }}
        {% end %}
        {% if result_type == "Crolog::Atom" %}
          raise "invalid result type" unless LibProlog.is_atom({{"p#{index}".id}}) == 1
          {{var_name.id}} = Crolog::Atom.new({{"p#{index}".id}})
        {% elsif result_type == "Int32" %}
          raise "invalid result type" unless LibProlog.is_integer({{"p#{index}".id}}) == 1
          {{var_name.id}} :: Int32
          LibProlog.get_integer({{"p#{index}".id}}, out {{var_name.id}})
        {% else %}
          {{ raise "not implemented" }}
        {% end %}
      {% end %}
    {% end %}

    {{ expr.block.body }}
  end
end
