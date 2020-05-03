# Lesson 1

Parsers are used to "read" a piece of text and turn it into some kind of data structure.  For example, we can design a parser that takes a string like "12/31/1954" and turns it into the record 

```
    { month = 12, day = 31, year = 1954}
```

We will learn to do this shortly.  For a more elaborate example, consider this sentence in the toy language `Arith`:

```
    if true then succ 0 else 0
```

When parsed, it is transformed into the data structure

```
    IfExpr T (Succ Zero) Zero)
```

While it may not look like it, this data structure is a tree, a so-called *abstract syntax tree*, or *AST*, as in the figure below. One of the jobs of a compiler is to compute AST's for the text of a program, then translate that tree into machine code.   

![ast](image/ast.jpg)

To summarize, parsers are used to construct functions

```
    f : Text -> Some Structure
```

The structure can be a date, and abstract syntax tree, etc.

## Primitive parsers

Parsers typically operate by reading a stream of characters one at a time, building up the structure as they go, eventually returning either the desired structure or an error.  Let's do an example with the primitive parser `int`.  A primitive parser is one that is given to us by the parser package — we don't have to construct it ourselves.  The `int` parser will read valid characters from its input and return either an integer or an error.  Let's see how this works (see the setup instructions if need be).
Start the Elm repl, then import the `elm/parser` package:

```
$ elm repl
> import Parser exposing(..)
```

Next, run the `int` parser on the string "34". The parser eats the characters 3 and 4 and returns the value `Ok 34`


```
> run int "34"
Ok 34 : Result (List DeadEnd) Int
```

The value, `Ok 34`, is a Result type, meaning that it can be either

```
    Ok (something we want) 
```

or

```
    Err (something we don't: an error)
```

Here is an example in which the parser fails:


```
    > run int "thirty-four"
    Err [{ col = 1, problem = ExpectingInt, row = 1 }]
        : Result (List DeadEnd) Int
```

The parser expected a digit, but got the character 't' instead. Let's note the type of our parser:

```
    int : Parser Int
```  

This means that it is a parser whose purpose in life is to eat characters, yielding an integer if successful, and an error if not 


### Other Primitive Parsers

Closely related to the `int` parser is `float`, which does what you think it does.  Another primitive is `symbol`, which is used to recognized a given string.  As example, the `symbol "a"` parser recognizes strings
that begin with "a":


```
    > run (symbol "a") "abc"
    Ok () : Result (List DeadEnd) ()
```

It rejects strings that begin with any other character:


```
    > run (symbol "x") "abc"
    Err [{ col = 1, problem = ExpectingSymbol "x", row = 1 }]
        : Result (List DeadEnd) ()
```

Let's note the type signature:

```
    symbol : String -> Parser ()
```

This `symbol` is not actually a parser: it is a function that when given 
a string returns a parser.  But a parser of what type? It is of type `()`. This is the *unit type*, a type which has just one value, also called `()`. What kind of information can such a parser give us?  Well, there are just two possibilities. When we run it on an input, it either succeeds, returning `Ok ()`, or fails returning `Err some-error`. Such a parser can tell us about success (recognizing a string, or "symbol") or failure (not recognizing it).

### The succeed parser


Here is the type of of the `succeed` parser:

```
    succeed : a -> Parser a
```

When run, it *always* succeed, returning the value *a*.

```
    > run (succeed 1234) "foo"
````

Thus `succeed 1234` will always succeed, returning 1234:

```
    > run (succeed 1234) "foo"
    Ok 1234 : Result (List DeadEnd) number
```

Here is what happens when we apply it to some other values:

```
   > run (succeed 1234) "76"
   Ok 1234
   
   > run (succeed 1234) "[1, 2, 89]"
   Ok 1234 : Result (List DeadEnd) number
```

No matter what we run it on, `succeed 1234` returns 1234.


## Combinators: selecting among alternatives

Combinators are functions that can be used to build new parsers
by combining existing ones.  Let's look first at the the `oneOf` combinator.  It allows us to select among alternatives.  As an example,
we build a parser which recognizes strings that begin with the letter
"a" or the letter "b":


```
    > run (oneOf [symbol "a", symbol "b"]) "abc"
    Ok () 
```

The `oneOf` parser takes a list of parsers and applies them to the 
input one-by-one, beginning with the left-most parser. The combined
parser succeeds if one of its component parsers succeeds.  If none
of them succeeds, it fails.  First another example of success:


```
    > run (oneOf [symbol "a", symbol "b"]) "bbb"
    Ok ()
```

and then an example of failure:

```
    > run (oneOf [symbol "a", symbol "b"]) "ccc"
    Err [{ col = 1, problem = ExpectingSymbol "a", row = 1 },{ col = 1,  
        problem = ExpectingSymbol "b", row = 1 }]
```

## Combinators: sequencing

Parsers can also be combined one after another.  We will give the example of a parser for dates, then explain how it works.  First, we define a type for dates:

```
    type alias Date =
        { day : Int
        , month : Int
        , year : Int
        }
```

It is important to note that whenever we define a record, as we have just done, we also define function that constructs records from data:

```
    Date : Int -> Int -> Int -> Date
```

Because of its role, a function of this kind is called a *constructor*. An any case, you can verify the truth of this discussion using the repl:

```
    > import Example.Simple exposing(..)
    > Date
    <function> : Int -> Int -> Int -> Date
```

Thus `Date 31 1 2000` constructs the `Date` value that we think of as 31/1/2000, that is, January 31, 2000.  Here is a parser for `Date` values:

```
    date : Parser Date
    date =
        succeed Date
            |= int
            |. symbol "/"
            |= int
            |. symbol "/"
            |= int
```

And here is how it works:


```
    > run date "31/1/2000"
    Ok { day = 31, month = 1, year = 2000 }
```
