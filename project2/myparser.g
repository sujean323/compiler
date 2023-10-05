grammar myparser;

options {
   language = Java;
}

@header {
    // import packages here.
}

@members {
    boolean TRACEON = true;
}

program:VOID_TYPE MAIN '(' ')' '{' declarations statements '}'
        {if (TRACEON) System.out.println("VOID MAIN () {declarations statements}");}
      | INT_TYPE MAIN '(' ')' '{' declarations statements '}' 
        {if (TRACEON) System.out.println("INT MAIN () {declarations statements}");};

declarations:type ID ';' declarations
              { if (TRACEON) System.out.println("declarations: type ID : declarations"); }
            | type ID '=' arith_expression ';' declarations
              { if (TRACEON) System.out.println("declarations: type ID = digit : declarations");} 
            | type ID '[' DEC_NUM ']' ';' declarations
              { if (TRACEON) System.out.println("declarations: type ID[array_size] : declarations");}
            | { if (TRACEON) System.out.println("declarations: ");} ;

type:INT_TYPE { if (TRACEON) System.out.println("type: INT"); }
   | FLOAT_TYPE {if (TRACEON) System.out.println("type: FLOAT"); }
   | SHORT_TYPE {if (TRACEON) System.out.println("type: SHORT"); }
   | LONG_TYPE {if (TRACEON) System.out.println("type: LONG"); }
   | CHAR_TYPE {if (TRACEON) System.out.println("type: CHAR"); }
   | DOUBLE_TYPE {if (TRACEON) System.out.println("type: DOUBLE"); }
   | SIGNED_TYPE {if (TRACEON) System.out.println("type: SIGNED"); }
   | UNSIGNED_TYPE {if (TRACEON) System.out.println("type: UNSIGNED"); }
   | VOID_TYPE {if (TRACEON) System.out.println("type: VOID"); }
   | CONST_TYPE {if (TRACEON) System.out.println("type: CONST"); };

statements:statement statements | ;

pre_logic_expression: pre_arith_expression
                      ( '!' pre_arith_expression
                      | '&&' pre_arith_expression
                      | '||' pre_arith_expression
                      )*
                      ;

pre_arith_expression: arith_expression
                      ( '>' arith_expression
                      | '<' arith_expression
                      | '==' arith_expression
                      | '>=' arith_expression
                      | '<=' arith_expression
                      )*
                      ;

arith_expression: multExpr
                  ( '+' multExpr
				  | '-' multExpr
                  | '^' multExpr
                  | '%' multExpr
				  )*
                  ;

multExpr: signExpr
          ( '*' signExpr
          | '/' signExpr
		  )*
		  ;

signExpr: primaryExpr
        | '-' primaryExpr
		;


primaryExpr: DEC_NUM
           | DEC_NUM PP_OP
           | DEC_NUM MM_OP
           | FLOAT_NUM
           | ID
           | ID PP_OP
           | ID MM_OP
		   | '(' arith_expression ')'
           | SIZEOF_ '(' ID ')';

statement: ID '=' pre_arith_expression ';' {
            if(TRACEON){
                System.out.println("ID = pre_arith_expression");
            }
         }
         | ID PP_OP ';' {
            if(TRACEON){
                System.out.println("ID++");
            }
         }
         | ID MM_OP ';' {
            if(TRACEON){
                System.out.println("ID--");
            }
         } 
         | PRINTF '(' LITERAL (',' pre_arith_expression)* ')' ';' {
            if(TRACEON){
                System.out.println("function: printf");
            }
         }
         | SCANF '(' LITERAL (',' ('&')? pre_arith_expression)* ')' ';' {
            if(TRACEON){
                System.out.println("function: scanf");
            }
         }
         | STRCPY '(' ID ',' (LITERAL|ID) ')' ';' {
            if(TRACEON){
                System.out.println("function: strcpy");
            }
         }
         | ID '=' STRLEN '(' (LITERAL|ID) ')' ';'{
            if(TRACEON){
                System.out.println("function: strlen");
            }
         }
         | IF_ '(' pre_logic_expression ')' if_statements (options{greedy=true;}: (ELSE_ if_statements))?
         | FOR_ '(' ID '=' arith_expression ';' pre_arith_expression ';' arith_expression ')' if_statements{
            if(TRACEON){
                System.out.println("for loop");
            }
         }
         | WHILE_ '(' pre_logic_expression ')' if_statements{
            if(TRACEON){
                System.out.println("while loop");
            }
         }
         | SWITCH_ '(' pre_logic_expression ')' '{' (CASE_ DEC_NUM ':' statements BREAK_ ';')* DEFAULT_ ':' statements (BREAK_ ';')? '}'{
            if(TRACEON){
                System.out.println("switch case");
            }
         }
         | RETURN_ pre_logic_expression ';' ;

if_statements: statement
             | '{' statements '}'
             ;
         

/* description of the tokens */


/*----------------------*/
/*      functions       */
/*----------------------*/
MAIN  : 'main';
PRINTF: 'printf';
SCANF : 'scanf';
STRCMP: 'strcmp';
STRCPY: 'strcpy';
STRLEN: 'strlen';



/*----------------------*/
/*   Reserved Keywords  */
/*----------------------*/
INT_TYPE     : 'int';
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
BREAK_       : 'break';
CONTINUE_    : 'continue';
TYPEDEF_     : 'typedef';
STRUCT_      : 'struct';
UNOIN_       : 'union';




/*----------------------*/
/*  Compound Operators  */
/*----------------------*/
AND_OP    : '&&';
OR_OP     : '||';
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
XOR_OP:              '^';
NOT_LOGIC_OP:        '!';
NOT_BITWISE_OP:      '~';
GT_OP:               '>';
LT_OP:               '<';
PLUS_OP:             '+';
MUNUS_OP:            '-';
MULTI_OP_OR_POINTER: '*';
DIV_OP:              '/';
MODULO_OP:           '%';
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

WS: (' '|'\r'|'\t')+{$channel=HIDDEN;};
NEW_LINE: '\n' {$channel=HIDDEN;};

/* Comments */
COMMENT1 : '//'(.)*'\n' {$channel=HIDDEN;};
COMMENT2 : '/*' (options{greedy=false;}: .)* '*/' {$channel=HIDDEN;};

ID : (LETTER)(LETTER | DIGIT)*;
DEC_NUM : ('0' | ('1'..'9')(DIGIT)*);
LITERAL : '"'(.)*'"';
FLOAT_NUM: FLOAT_NUM1 | FLOAT_NUM2 | FLOAT_NUM3;
fragment FLOAT_NUM1: (DIGIT)+'.'(DIGIT)*;
fragment FLOAT_NUM2: '.'(DIGIT)+;
fragment FLOAT_NUM3: (DIGIT)+;
fragment LETTER : 'a'..'z' | 'A'..'Z' | '_';
fragment DIGIT : '0'..'9';

 











