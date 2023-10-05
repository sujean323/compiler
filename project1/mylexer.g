lexer grammar test1;

options {
  language = Java;
}


/*----------------------*/
/*      functions       */
/*----------------------*/
MAIN  : 'main';
PRINTF: 'printf';
SCANF : 'scanf';
STRCMP: 'strcmp';



/*----------------------*/
/*   Reserved Keywords  */
/*----------------------*/
INT_TYPE     : 'integer';
CHAR_TYPE    : 'char';
VOID_TYPE    : 'void';
FLOAT_TYPE   : 'float';
DOUBLE_TYPE  : 'double';
CONST_TYPE   : 'const';
STATIC_      : 'static';   
UNSIGNED_TYPE: 'unsigned';
SIGNED_TYPE  : 'signed';
SHORT_TYPE   : 'short';
LONG_TYPE    : 'long';
FOR_         : 'for';
DO_          : 'do';
WHILE_       : 'while';
IF_          : 'if';
ELSE_        : 'else';
SWITCH_      : 'switch';
CASE_        : 'case';
DEFAULT_     : 'default';
RETURN_      : 'return';
SIZEOF_      : 'sizeof';
BREAK_       : 'break'
CONTINUE_    : 'continue';
TYPEDEF_     : 'typedef';
STRUCT_      : 'struct';
UNOIN_       : 'union';




/*----------------------*/
/*  Compound Operators  */
/*----------------------*/
AND_OP    : '&&'
OR_OP     : '||'
EQ_OP     : '==';
LE_OP     : '<=';
GE_OP     : '>=';
NE_OP     : '!=';
PP_OP     : '++';
MM_OP     : '--'; 
RSHIFT_OP : '<<';
LSHIFT_OP : '>>';


/*----------------------*/
/*   Single Operators   */
/*----------------------*/

ASSIGN_OP:           '=';
AND_OP:              '&';
OR_OP:               '|';
XOR_OP:              '^';
NOT_LOGIC_OP:        '!';
NOT_BITWISE_OP:      '~';
GT_OP:               '>';
LT_OP:               '<';
PLUS_OP:             '+';
MUNUS_OP:            '-';
MULTI_OP_OR_POINTER: '*';
DIV_OP:              '/';
COLON:               ':';
COMMA:               ',';
SEMICOLON:           ';';
DOT_OP:              '.';
LEFT_PAREM:          '(';
RIGHT_PAREM:         ')';
LEFT_BRACKET:        '[';
RIGHT_BRACKET:       ']';
LEFT_BRACE:          '{';
RIGHT_BRACE:         '}';



DEC_NUM : ('0' | ('1'..'9')(DIGIT)*);

ID : (LETTER)(LETTER | DIGIT)*;

FLOAT_NUM: FLOAT_NUM1 | FLOAT_NUM2 | FLOAT_NUM3;
fragment FLOAT_NUM1: (DIGIT)+'.'(DIGIT)*;
fragment FLOAT_NUM2: '.'(DIGIT)+;
fragment FLOAT_NUM3: (DIGIT)+;
 

/* Comments */
COMMENT1 : '//'(.)*'\n';
COMMENT2 : '/*' (options{greedy=false;}: .)* '*/';


NEW_LINE: '\n';

fragment LETTER : 'a'..'z' | 'A'..'Z' | '_';
fragment DIGIT : '0'..'9';


WS  : (' '|'\r'|'\t')+
    ;
