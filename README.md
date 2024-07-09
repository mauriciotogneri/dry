# Dry
Dry is a purely functional programming language that emphasizes functions and immutability. It doesn't have statements, only declarations.

### Literal
Number | String | Boolean

### Symbol
Identifier

### Parameters
Symbol[,Symbol]*

### FunctionCall
Symbol([Parameters]*)

### Expression
Literal | FunctionCall

### Function definition
Symbol=Expression

Internal types
* String
* Boolean
* Number
* Array
* Function

Expression extends Typed, Evaluated

Features
* types (start with uppercase)
* curryfication
* tuples book = { title, author, pages }
* x:xs