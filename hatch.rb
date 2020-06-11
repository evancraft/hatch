  #expressions
  
  class Expression
    def initialize(name)
      @name = name
    end
  
    def self.define_attr(attr)
      define_method(attr) do
        instance_variable_get("@#{attr}")
      end
  
      define_method("#{attr}=") do |val|
        instance_variable_set("@#{attr}", val)
      end
    end
  end

  def skipspace(string)
    skippable = string.match(/^(\s|#.*)*/);
    string.slice! skippable[0]
    string
  end
  
  def translate(program)
    program = skipspace(program)
    match = program.match(/^"([^"]*)"/)
    if match 
      val = match[1];
      expr = Expression.new("expr")
      Expression.define_attr(:type)
      Expression.define_attr(:state)
      puts("string")
      expr.type = "string"
      expr.state = val
      program.slice! match[0]
      return scribe(expr, program)
    end  
    match = program.match(/^\d+\b/)
    if match
      val = match[0];
      expr = Expression.new("expr")
      Expression.define_attr(:type)
      Expression.define_attr(:state)
      puts("number")
      expr.type = "number"
      expr.state = val
      program.slice! match[0]
      return scribe(expr, program)
    end    
    match = program.match(/^[^\s(),"]+/)
    if match
      val = match[0];
      expr = Expression.new("expr")
      Expression.define_attr(:type)
      Expression.define_attr(:name)
      puts("structure")
      expr.type = "structure"
      expr.name = val
      program.slice! match[0]
      return scribe(expr, program)
    end    
  end
  
  
  def scribe (exprx, program)
    program = skipspace(program);
    puts program
    if (program[0] != "(")
        expr = Expression.new("expr")
        Expression.define_attr(:expr)
        Expression.define_attr(:rest)
        expr.expr = exprx
        expr.rest = program
      return expr
    end
  
    program.slice! program[0]
    program = skipspace(program);
    expr = Expression.new("expr")
    Expression.define_attr(:type)
    Expression.define_attr(:operator)
    Expression.define_attr(:args)
    expr.type = "command"
    expr.operator = exprx
    expr.args = []
  
    while (program[0] != ")") 
      arg = translate(program);
      expr.args.push(arg.expr);
      program = skipspace(arg.rest);
      if (program[0] == ',') 
        program.slice! program[0]
        program = skipspace(program);
      elsif (program[0] != ")")
      end
    end
    program.slice! program[0]
    return scribe(expr, program)
  end
  
  def parse (program)
    result = translate(program);
    if (skipspace(result.rest).length > 0)
    end
    return result.expr;
  end
  
  def evaluate (expr, con, struct)
    case(expr.type)
    when "state"
        puts "STATE"
        return expr.state
    when "structure"
        puts "STRUCTURE"
        givenName = expr.name
        return con.send(givenName)
    when "command"
        puts "Running Application..."
        if (expr.operator.type == "structure" && expr.operator.name == "$") 
            return struct.method('assign').call(expr.args, con)
        end
    else
    end   
  end

  #arguments

  class Argument
    def initialize(name)
      @name = name
    end
  
    def self.define_attr(attr)
      define_method(attr) do
        instance_variable_get("@#{attr}")
      end
  
      define_method("#{attr}=") do |val|
        instance_variable_set("@#{attr}", val)
      end
    end
  
  end
  
  #constructs
  
  class Construct
    def initialize(name)
      @name = name
    end
  
    def self.define_attr(attr)
      define_method(attr) do
        instance_variable_get("@#{attr}")
      end
  
      define_method("#{attr}=") do |val|
        instance_variable_set("@#{attr}", val)
      end
    end

    def assign(args, con)
      index = con.args.length
      con.args[index] = Argument.new(args[0].name)
      Argument.define_attr(:name)
      Argument.define_attr(:state)
      con.args[index].name = args[0].name;
      con.args[index].state = args[1].state;
      puts("VARIABLE ASSIGNED -> " + con.args[index].name + ":" + con.args[index].state)
      puts 
      return con.args[index]
    end

  end
  
  construct = Construct.new("construct")
  
  #context
  
  class Context
    def initialize(name)
      @name = name
    end
  
    def self.define_attr(attr)
      define_method(attr) do
        instance_variable_get("@#{attr}")
      end
  
      define_method("#{attr}=") do |val|
        instance_variable_set("@#{attr}", val)
      end
    end
  end
  
  context = Context.new("context")
  Context.define_attr(:true)
  Context.define_attr(:false)
  Context.define_attr(:args)
  
  context.true = true;
  context.false = false;
  context.args = [];

  def interpreter(program, con, struct)
    puts "Parsing..."
    puts program
    expression = parse(program)
    evaluate(expression, con, struct)
  end

  interpreter("$(a,12)", context, construct)
  interpreter("$(b,13)", context, construct)