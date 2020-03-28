describe 'Q grammar tests', ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage('language-shakti-k')
    runs ->
      grammar = atom.grammars.grammarForScopeName('source.k')

  it 'checks the grammar', ->
    expect(grammar).toBeTruthy()
    expect(grammar.scopeName).toBe 'source.k'

  it 'checks control token', ->
    {tokens} = grammar.tokenizeLine 'do[10;20]'

    expect(tokens.length).toEqual 6

    expect(tokens[0]).toEqual
      value: 'do'
      scopes: [
        'source.k'
        'keyword.control.k'
      ]

    expect(tokens[1]).toEqual
      value: '['
      scopes: [
        'source.k'
        'meta.brace.open.k'
      ]

    expect(tokens[2]).toEqual
      value: '10'
      scopes: [
        'source.k'
        'constant.numeric.k'
      ]

    expect(tokens[3]).toEqual
      value: ';'
      scopes: [
        'source.k'
        'meta.punctuation.k'
      ]

    expect(tokens[4]).toEqual
      value: '20'
      scopes: [
        'source.k'
        'constant.numeric.k'
      ]

    expect(tokens[5]).toEqual
      value: ']'
      scopes: [
        'source.k'
        'meta.brace.close.k'
      ]

  it 'checks operator token', ->
    {tokens} = grammar.tokenizeLine 'a , b lj x'

    expect(tokens.length).toEqual 9

    expect(tokens[0]).toEqual
      value: 'a'
      scopes: [
        'source.k'
        'entity.name.k'
      ]

    expect(tokens[1]).toEqual
      value: ' '
      scopes: [
        'source.k'
      ]

    expect(tokens[2]).toEqual
      value: ','
      scopes: [
        'source.k'
        'keyword.operator.k'
      ]

    expect(tokens[8]).toEqual
      value: 'x'
      scopes: [
        'source.k'
        'variable.language.k'
      ]

  it 'checks block comment', ->
    lines = grammar.tokenizeLines '/  \n    some comment\n\\  '

    expect(lines.length).toEqual 3

    for l in lines
      expect(l.length).toEqual 1
      expect(l[0].scopes).toEqual ['source.k', 'comment.block.simple.k']

  it 'checks line comment', ->
    {tokens} = grammar.tokenizeLine '/ some comment'

    expect(tokens.length).toEqual 1

    expect(tokens[0].scopes).toEqual ['source.k','comment.line.k']

    {tokens} = grammar.tokenizeLine 'txt / another comment'

    expect(tokens.length).toEqual 2

    expect(tokens[1].scopes).toEqual ['source.k','comment.line.k']

    {tokens} = grammar.tokenizeLine 'do not comment this/[arg]'

    expect(tokens.length).toEqual 11

    expect(tokens[9]).toEqual
      value: 'arg'
      scopes: [
        'source.k'
        'entity.name.k'
      ]

  it 'checks eof block comment', ->
    lines = grammar.tokenizeLines '\\  \n  /\n  some comment\n\\ \n aaa'

    expect(lines.length).toEqual 5

    for l in lines
      expect(l.length).toEqual 1
      expect(l[0].scopes).toEqual ['source.k', 'comment.block.eof.k']

  it 'checks Q cmd line', ->
    {tokens} = grammar.tokenizeLine '\\some cmd'

    expect(tokens.length).toEqual 1

    expect(tokens[0]).toEqual
      value: '\\some cmd'
      scopes: [
        'source.k'
        'constant.other.k'
      ]

  it 'checks string token', ->
    {tokens} = grammar.tokenizeLine '"str" "aaa\\nb\\tc\\""'

    expect(tokens.length).toEqual 12

    expect(tokens[0]).toEqual
      value: '"'
      scopes: [
        'source.k'
        'string.kuoted.single.k'
      ]

    expect(tokens[5]).toEqual
      value: 'aaa'
      scopes: [
        'source.k'
        'string.kuoted.single.k'
      ]

    expect(tokens[6]).toEqual
      value: '\\n'
      scopes: [
        'source.k'
        'string.kuoted.single.k'
        'constant.character.escape.k'
      ]

  it 'checks functions', ->
    {tokens} = grammar.tokenizeLine 'first 0nh 0xAf12'

    expect(tokens.length).toEqual 5

    expect(tokens[0]).toEqual
      value: 'first'
      scopes: [
        'source.k'
        'support.function.k'
      ]

    expect(tokens[2]).toEqual
      value: '0nh'
      scopes: [
        'source.k'
        'constant.language.k'
      ]

    expect(tokens[4]).toEqual
      value: '0xAf12'
      scopes: [
        'source.k'
        'constant.numeric.k'
      ]

  it 'checks timestamp/span tokens', ->
    {tokens} = grammar.tokenizeLine '10D 10D10 10D10:10 10D10:10:10 10D10:10:10.11 10Dz 10D10p 10D10:10n 10D10:10:10z 10D10:10:10.11p \
      2001.10.10D 2001.10.10D10 2001.10.10D10:10 2001.10.10D10:10:10 2001.10.10D10:10:10.11 \
      2001.10.10Dz 10D10p 2001.10.10D10:10n 2001.10.10D10:10:10z 2001.10.10D10:10:10.11p'

    expect(tokens.length).toEqual 39

    for t in tokens by 2
      expect(t.scopes).toEqual  ['source.k','constant.numeric.k']
