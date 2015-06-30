macro export_rule(expr)
  %callback = -> (%t : LibProlog::Term) {
    {% for arg, index in expr.args %}
      {{arg.name}} = Crolog::Term.new(term_n(%t, {{index}}))
    {% end %}
    {{expr.body}}
  }
  LibProlog.register_foreign({{expr.name.stringify}}, {{expr.args.length}}, (%callback.pointer as LibProlog::PLFunction), LibProlog::PL_FA_VARARGS)
end
