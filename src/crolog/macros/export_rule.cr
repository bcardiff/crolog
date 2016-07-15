macro export_rule(expr)
  %callback = -> (%t : LibProlog::Term) {
    {% for arg, index in expr.args %}
      # {{arg.name}} = Crolog::Term.new(term_n(%t, {{index}}))
      {{arg.name}} = Crolog::Term.new((((%t as UInt8*) + {{index}}) as LibProlog::Term))
    {% end %}
    {{expr.body}}
  }
  LibProlog.register_foreign({{expr.name.stringify}}, {{expr.args.size}}, (%callback.pointer as LibProlog::PLFunction), LibProlog::PL_FA_VARARGS)
end
