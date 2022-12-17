module Solargraph
  class YardMap
    module CoreFills
      Override = Pin::Reference::Override

      KEYWORDS = [
        '__ENCODING__', '__LINE__', '__FILE__', 'BEGIN', 'END', 'alias', 'and',
        'begin', 'break', 'case', 'class', 'def', 'defined?', 'do', 'else',
        'elsif', 'end', 'ensure', 'false', 'for', 'if', 'in', 'module', 'next',
        'nil', 'not', 'or', 'redo', 'rescue', 'retry', 'return', 'self', 'super',
        'then', 'true', 'undef', 'unless', 'until', 'when', 'while', 'yield'
      ].map { |k| Pin::Keyword.new(k) }

      methods_with_yieldparam_subtypes = %w[
        Array#each Array#map Array#map! Array#any? Array#all? Array#index
        Array#keep_if Array#delete_if
        Enumerable#each_entry Enumerable#map Enumerable#any? Enumerable#all?
        Enumerable#select Enumerable#reject
        Set#each
      ]

      OVERRIDES = [
        Override.method_return('Array#concat', 'Array'),
        Override.method_return('Array#keep_if', 'self'),
        Override.method_return('Array#delete_if', 'self'),
        Override.from_comment('Array#map', %(
@overload map(&block)
  @return [Array]
@overload map()
  @return [Enumerator]
        )),
        Override.from_comment('Array#reject', %(
@overload reject(&block)
  @return [self]
@overload reject()
  @return [Enumerator]
        )),
        Override.method_return('Array#reverse', 'self', delete: ['overload']),
        Override.from_comment('Array#select', %(
@overload select(&block)
  @return [self]
@overload select()
  @return [Enumerator]
        )),
        Override.from_comment('Array#[]', %(
@overload [](range)
  @param range [Range]
  @return [self]
@overload [](num1, num2)
  @param num1 [Integer]
  @param num2 [Integer]
  @return [self]
@overload [](num)
  @param num [Integer]
  @return_single_parameter
@return_single_parameter
        )),
        Override.from_comment('Array#first', %(
@overload first(num)
  @param num [Integer]
  @return [self]
@return_single_parameter
        )),
        Override.from_comment('Array#last', %(
@overload last(num)
  @param num [Integer]
  @return [self]
@return_single_parameter
        )),
        Override.method_return('Array#map', 'Array'),
        Override.method_return('Array#uniq', 'self'),
        Override.method_return('Array#zip', 'Array, nil'),

        Override.from_comment('BasicObject#==', %(
@param other [BasicObject]
@return [Boolean]
        )),
        Override.method_return('BasicObject#initialize', 'void'),

        Override.method_return('Class#new', 'self'),
        Override.method_return('Class.new', 'Class<Object>'),
        Override.method_return('Class#allocate', 'self'),
        Override.method_return('Class.allocate', 'Class<Object>'),

        Override.from_comment('Enumerable#detect', %(
@overload detect(&block)
  @return_single_parameter
@overload detect()
  @return [Enumerator]
        )),
        Override.from_comment('Enumerable#find', %(
@overload find(&block)
  @return_single_parameter
@overload find()
  @return [Enumerator]
        )),
        Override.method_return('Enumerable#select', 'self'),

        Override.method_return('File.absolute_path', 'String'),
        Override.method_return('File.basename', 'String'),
        Override.method_return('File.dirname', 'String'),
        Override.method_return('File.extname', 'String'),
        Override.method_return('File.join', 'String'),
        Override.method_return('File.open', 'File'),

        Override.from_comment('Float#+', %(
@param y [Numeric]
@return [Numeric]
        )),

        Override.from_comment('Hash#[]', %(
@return_value_parameter
        )),
        # @todo This override isn't robust enough. It needs to allow for
        #   parameterized Hash types, e.g., [Hash{Symbol => String}].
        Override.from_comment('Hash#[]=', %(
@param_tuple
        )),
        Override.method_return('Hash#merge', 'Hash'),
        Override.from_comment('Hash#store', %{
@overload store(key, value)
        }),

        Override.from_comment('Integer#+', %(
@param y [Numeric]
@return [Numeric]
        )),
        Override.from_comment('Integer#times', %(
@overload times(&block)
  @return [Integer]
@overload times()
  @return [Enumerator]
        )),

        Override.method_return('Kernel#puts', 'nil'),

        Override.from_comment('Numeric#+', %(
@param y [Numeric]
@return [Numeric]
        )),

        Override.method_return('Object#!', 'Boolean'),
        Override.method_return('Object#clone', 'self', delete: [:overload]),
        Override.method_return('Object#dup', 'self', delete: [:overload]),
        Override.method_return('Object#freeze', 'self', delete: [:overload]),
        Override.method_return('Object#inspect', 'String'),
        Override.method_return('Object#taint', 'self'),
        Override.method_return('Object#to_s', 'String'),
        Override.method_return('Object#untaint', 'self'),
        Override.from_comment('Object#tap', %(
@return [self]
@yieldparam [self]
        )),

        Override.from_comment('STDERR', %(
@type [IO]
        )),

        Override.from_comment('STDIN', %(
@type [IO]
        )),

        Override.from_comment('STDOUT', %(
@type [IO]
        )),

        Override.method_return('String#freeze', 'self'),
        Override.method_return('String#split', 'Array<String>'),
        Override.method_return('String#lines', 'Array<String>'),
        Override.from_comment('String#each_line', %(
@yieldparam [String]
        )),
        Override.from_comment('String.new', %(
@overload new(*)
  @return [self]
      ))
      ].concat(
        methods_with_yieldparam_subtypes.map do |path|
          Override.from_comment(path, %(
@yieldparam_single_parameter
            ))
        end
      )

      PINS = [
        # HACK: Extending Hash is not accurate to the implementation, but
        # accurate enough to the behavior
        Pin::Reference::Extend.new(closure: Pin::Namespace.new(name: 'ENV'), name: 'Hash'),
        Pin::Reference::Superclass.new(closure: Pin::Namespace.new(name: 'File'), name: 'IO'),
        Pin::Reference::Superclass.new(closure: Pin::Namespace.new(name: 'Integer'), name: 'Numeric'),
        Pin::Reference::Superclass.new(closure: Pin::Namespace.new(name: 'Float'), name: 'Numeric')
      ].concat(
        # HACK: Add Errno exception classes
        begin
          errno = Solargraph::Pin::Namespace.new(name: 'Errno')
          result = []
          Errno.constants.each do |const|
            result.push Solargraph::Pin::Namespace.new(type: :class, name: const.to_s, closure: errno)
            result.push Solargraph::Pin::Reference::Superclass.new(closure: result.last, name: 'SystemCallError')
          end
          result
        end
      )

      ALL = KEYWORDS + PINS + OVERRIDES
    end
  end
end
