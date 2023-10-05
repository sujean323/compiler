grammar myChecker;

@header {
    // import packages here.
    import java.util.HashMap;
}

@members {
    boolean TRACEON = true;
	public enum TypeT {
		SIGNED_INT,
		UNSIGNED_INT,
		SHORT,	// short are signed.
		LONG,	// long are signed.
		FLOAT,
		DOUBLE,
		CHAR,
		VOID,
		BOOL,
		UNDEFINED,
	}
    public HashMap<String,TypeT> symbolTable = new HashMap<String, TypeT>();
	public static void err(String msg, int line) {
			System.err.println("error! " + line +  ": " + msg );
			// System.exit(1);
	}
	public static TypeT assertTypeSame(TypeT t1, TypeT t2, int line) {
		if (t1 != t2) {
			err("type are not the same, t1=" + t1.name() + ", t2=" + t2.name(), line);
		}
		return t1;
	}
	public static TypeT assertTypeSame(TypeT t1, TypeT t2, String msg, int line) {
		if (t1 != t2) {
			err(msg, line);
		}
		return t1;
	}
	public TypeT typeOfID(String IdName) {
		return typeOfID(IdName, 0);
	}
	public TypeT typeOfID(String IdName, int line) {
		if (!symbolTable.containsKey(IdName)) {
			err("Undeclared identifier.", line);
			return TypeT.UNDEFINED;
		}
		return symbolTable.get(IdName);
	}
}

program:
	VOID_TYPE MAIN '(' ')' '{' declarations statements '}' {if (TRACEON) System.out.println("VOID MAIN () {declarations statements}");
		}
	| INT_TYPE MAIN '(' ')' '{' declarations statements '}' {if (TRACEON) System.out.println("INT MAIN () {declarations statements}");
		};

declarations:
	type ID ';'
	{ 
		if (TRACEON) System.out.println("declarations: type ID : declarations"); 
		// 判斷 symbol 是否存在 symbol table, 如果存在就是重複宣告，編譯失敗。
		if (symbolTable.containsKey($ID.text)) {
			// error: re-define variable
			err("Redefine identifier " + $ID.text, $ID.getLine());
		} else {
			symbolTable.put($ID.text.toString(),  $type.typeT);
		}
		
	}
	 declarations 
	| type ID '=' arith_expression ';'  { 
		if (TRACEON) System.out.println("declarations: type ID = digit : declarations");
		if (symbolTable.containsKey($ID.text)) {
			// error: re-define variable
			err("Redefine identifier " + $ID.text, $ID.getLine());
		} else {
			symbolTable.put($ID.text.toString(),  $type.typeT);
		}
		
	} declarations
	| type ID '[' DEC_NUM ']' ';' { 
		if (TRACEON) System.out.println("declarations: type ID[array_size] : declarations");
		//err("array is currently not implemented.", $type.start.getLine());
	} declarations 
	| { if (TRACEON) System.out.println("declarations: ");};

type
	returns[TypeT typeT]:
	INT_TYPE { 
		if (TRACEON) System.out.println("type: INT"); 
		$typeT = TypeT.SIGNED_INT;
	}
	| FLOAT_TYPE {
		if (TRACEON) System.out.println("type: FLOAT"); 
		$typeT = TypeT.FLOAT;
	}
	| SHORT_TYPE {
		if (TRACEON) System.out.println("type: SHORT"); 
		$typeT = TypeT.SHORT;
	}
	| LONG_TYPE {
		if (TRACEON) System.out.println("type: LONG"); 
		$typeT = TypeT.LONG;
	}
	| CHAR_TYPE {
		if (TRACEON) System.out.println("type: CHAR");
		$typeT = TypeT.CHAR;
	}
	| DOUBLE_TYPE {
		if (TRACEON) System.out.println("type: DOUBLE");
		$typeT = TypeT.DOUBLE;
	}
	| SIGNED_TYPE INT_TYPE? {
		if (TRACEON) System.out.println("type: SIGNED");
		$typeT = TypeT.SIGNED_INT;
	}
	| UNSIGNED_TYPE INT_TYPE? {
		if (TRACEON) System.out.println("type: UNSIGNED");
		$typeT = TypeT.UNSIGNED_INT;
	}
	| VOID_TYPE {
		if (TRACEON) System.out.println("type: VOID"); 
		$typeT = TypeT.VOID;
	}
	;

statements: statement statements |;

pre_logic_expression
	returns[TypeT typeT]:
	a = pre_arith_expression {$typeT = $a.typeT;} (
		'||' b = pre_arith_expression {
				if ($a.typeT != $b.typeT)
				{
					err("Type mismatch for the operator || in an expression. " , $a.start.getLine());
					$typeT = TypeT.UNDEFINED;
				}
				else
				{
					$typeT = TypeT.BOOL;
				}
			}
		| '&&' c = pre_arith_expression {
				if ($a.typeT != $c.typeT)
				{
					err("Type mismatch for the operator && in an expression. " , $a.start.getLine());
					$typeT = TypeT.UNDEFINED;
				}
				else
				{
					$typeT = TypeT.BOOL;
				}
			}
		| '!' d = pre_arith_expression {
				if ($a.typeT != $d.typeT)
				{
					err("Type mismatch for the operator ! in an expression. " , $a.start.getLine());
					$typeT = TypeT.UNDEFINED;
				}
				else
				{
					$typeT = TypeT.BOOL;
				}
			}
	)*;

pre_arith_expression
	returns[TypeT typeT]:
	ae1 = arith_expression {$typeT = $ae1.typeT;} (
		'>' arith_expression {$typeT = TypeT.BOOL;}
		| '<' arith_expression {$typeT = TypeT.BOOL;}
		| '==' arith_expression {$typeT = TypeT.BOOL;}
		| '>=' arith_expression {$typeT = TypeT.BOOL;}
		| '<=' arith_expression {$typeT = TypeT.BOOL;}
	)*;

arith_expression
	returns[TypeT typeT]:
	me1 = multExpr {$typeT = $me1.typeT;} (
		'+' me2 = multExpr {assertTypeSame($typeT, $me2.typeT, $me1.start.getLine());}
		| '-' me2 = multExpr {assertTypeSame($typeT, $me2.typeT, $me1.start.getLine());}
		| '^' me2 = multExpr {assertTypeSame($typeT, $me2.typeT, $me1.start.getLine());}
		| '%' me2 = multExpr {assertTypeSame($typeT, $me2.typeT, $me1.start.getLine());}
	)*;

multExpr
	returns[TypeT typeT]:
	e1 = signExpr {$typeT = $e1.typeT;} (
		'*' e2 = signExpr {assertTypeSame($typeT, $e2.typeT, $e1.start.getLine());}
		| '/' e2 = signExpr {assertTypeSame($typeT, $e2.typeT, $e1.start.getLine());}
	)*;

signExpr
	returns[TypeT typeT]:
	primaryExpr {$typeT = $primaryExpr.typeT;}
	| '-' primaryExpr {
	if ($primaryExpr.typeT == TypeT.UNSIGNED_INT) {
		$typeT = TypeT.SIGNED_INT;
	} else {
		$typeT = $primaryExpr.typeT;
	}
  };

primaryExpr
	returns[TypeT typeT]:
	DEC_NUM {$typeT = TypeT.SIGNED_INT;}
	| FLOAT_NUM {$typeT = TypeT.DOUBLE;}
	| ID {
		$typeT = typeOfID($ID.text.toString(), $ID.getLine());
	}
	| ID PP_OP {
		$typeT = typeOfID($ID.text.toString(), $ID.getLine());
	}
	| ID MM_OP {
		$typeT = typeOfID($ID.text.toString(), $ID.getLine());
	}
	| '(' arith_expression ')' {
		$typeT = $arith_expression.typeT;
	}
	| SIZEOF_ '(' ID ')' {
		$typeT = TypeT.UNSIGNED_INT;
	};
statement:
	ID '=' pae = pre_arith_expression ';' {
            if(TRACEON){
                System.out.println("ID = pre_arith_expression");
            }
			assertTypeSame(typeOfID($ID.text.toString(), $ID.getLine()), $pae.typeT, "Type mismatch for the two sides of an assignment.", $ID.getLine());
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
	| STRCPY '(' ID ',' (LITERAL | ID) ')' ';' {
            if(TRACEON){
                System.out.println("function: strcpy");
            }
         }
	| ID '=' STRLEN '(' (LITERAL | ID) ')' ';' {
            if(TRACEON){
                System.out.println("function: strlen");
            }
         }
	| IF_ '(' pre_logic_expression ')' if_statements (
		options {
			greedy = true;
		}: (ELSE_ if_statements)
		)? | FOR_ '(' ID '=' arith_expression ';' pre_arith_expression ';' arith_expression ')'
			if_statements {
            if(TRACEON){
                System.out.println("for loop");
            }
         } | WHILE_ '(' pre_logic_expression ')' if_statements {
            if(TRACEON){
                System.out.println("while loop");
            }
         } | SWITCH_ '(' pre_logic_expression ')' '{' (
			CASE_ DEC_NUM ':' statements BREAK_ ';'
		)* DEFAULT_ ':' statements (BREAK_ ';')? '}' {
            if(TRACEON){
                System.out.println("switch case");
            }
         } | RETURN_ pre_logic_expression ';';

	if_statements: statement | '{' statements '}';

	/* description of the tokens */

	/*----------------------*/
	/*      functions       */
	/*----------------------*/
	MAIN: 'main';
	PRINTF: 'printf';
	SCANF: 'scanf';
	STRCMP: 'strcmp';
	STRCPY: 'strcpy';
	STRLEN: 'strlen';

	/*----------------------*/
	/*   Reserved Keywords  */
	/*----------------------*/
	INT_TYPE: 'int';
	CHAR_TYPE: 'char';
	VOID_TYPE: 'void';
	FLOAT_TYPE: 'float';
	DOUBLE_TYPE: 'double';
	CONST_TYPE: 'const';
	STATIC_: 'static';
	UNSIGNED_TYPE: 'unsigned';
	SIGNED_TYPE: 'signed';
	SHORT_TYPE: 'short';
	LONG_TYPE: 'long';
	FOR_: 'for';
	DO_: 'do';
	WHILE_: 'while';
	IF_: 'if';
	ELSE_: 'else';
	SWITCH_: 'switch';
	CASE_: 'case';
	DEFAULT_: 'default';
	RETURN_: 'return';
	SIZEOF_: 'sizeof';
	BREAK_: 'break';
	CONTINUE_: 'continue';
	TYPEDEF_: 'typedef';
	STRUCT_: 'struct';
	UNOIN_: 'union';

	/*----------------------*/
	/*  Compound Operators  */
	/*----------------------*/
	AND_OP: '&&';
	OR_OP: '||';
	EQ_OP: '==';
	LE_OP: '<=';
	GE_OP: '>=';
	NE_OP: '!=';
	PP_OP: '++';
	MM_OP: '--';
	RSHIFT_OP: '<<';
	LSHIFT_OP: '>>';

	/*----------------------*/
	/*   Single Operators   */
	/*----------------------*/

	ASSIGN_OP: '=';
	XOR_OP: '^';
	NOT_LOGIC_OP: '!';
	NOT_BITWISE_OP: '~';
	GT_OP: '>';
	LT_OP: '<';
	PLUS_OP: '+';
	MUNUS_OP: '-';
	MULTI_OP_OR_POINTER: '*';
	DIV_OP: '/';
	MODULO_OP: '%';
	COLON: ':';
	COMMA: ',';
	SEMICOLON: ';';
	DOT_OP: '.';
	LEFT_PAREM: '(';
	RIGHT_PAREM: ')';
	LEFT_BRACKET: '[';
	RIGHT_BRACKET: ']';
	LEFT_BRACE: '{';
	RIGHT_BRACE: '}';

	WS: (' ' | '\r' | '\t')+ {$channel=HIDDEN;};
	NEW_LINE: '\n' {$channel=HIDDEN;};

	/* Comments */
	COMMENT1: '//' (.)* '\n' {$channel=HIDDEN;};
	COMMENT2: '/*' (options {greedy = false;
			}: .
			)* '*/' {$channel=HIDDEN;};

		ID: (LETTER) (LETTER | DIGIT)*;
		DEC_NUM: ('0' | ('1' ..'9') (DIGIT)*);
		LITERAL: '"' (.)* '"';
		FLOAT_NUM: FLOAT_NUM1 | FLOAT_NUM2 | FLOAT_NUM3;
		fragment FLOAT_NUM1: (DIGIT)+ '.' (DIGIT)*;
		fragment FLOAT_NUM2: '.' (DIGIT)+;
		fragment FLOAT_NUM3: (DIGIT)+;
		fragment LETTER: 'a' ..'z' | 'A' ..'Z' | '_';
		fragment DIGIT: '0' ..'9';

		