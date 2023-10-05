grammar myCompiler;

options {
   language = Java;
    backtrack=true;
}

@header {
    // import packages here.
    import java.util.HashMap;
    import java.util.ArrayList;
}

@members {
    boolean TRACEON = false;
	int scope=0;
    // Type information.
    public enum Type{
       ERR, BOOL, INT, SHORT, LONG, FLOAT, DOUBLE, CHAR, CONST_INT;
    }

    // This structure is used to record the information of a variable or a constant.
    class tVar {
	   int   varIndex; // temporary variable's index. Ex: t1, t2, ..., etc.
	   int   iValue;   // value of constant integer. Ex: 123.
	   float fValue;   // value of constant floating point. Ex: 2.314.
	};

    class Info {
       Type theType;  // type information.
       tVar theVar;
	   
	   Info() {
          theType = Type.ERR;
		  theVar = new tVar();
	   }
    };

	
    // ============================================
    // Create a symbol table.
	// ArrayList is easy to extend to add more info. into symbol table.
	//
	// The structure of symbol table:
	// <variable ID, [Type, [varIndex or iValue, or fValue]]>
	//    - type: the variable type   (please check "enum Type")
	//    - varIndex: the variable's index, ex: t1, t2, ...
	//    - iValue: value of integer constant.
	//    - fValue: value of floating-point constant.
    // ============================================

    HashMap<String, Info> symtab = new HashMap<String, Info>();

    // labelCount is used to represent temporary label.
    // The first index is 0.
    int labelCount = 0;
	
    // varCount is used to represent temporary variables.
    // The first index is 0.
    int varCount = 0;

    // Record all assembly instructions.
    List<String> TextCode = new ArrayList<String>();
    List<String> flabel = new ArrayList<String>();
    List<String> endlabel = new ArrayList<String>();


    /*
     * Output prologue.
     */
    void prologue()
    {
       TextCode.add("; === prologue ====");
       TextCode.add("declare dso_local i32 @printf(i8*, ...)\n");
	   TextCode.add("define dso_local i32 @main()");
	   TextCode.add("{");
    }
    
	
    /*
     * Output epilogue.
     */
    void epilogue()
    {
       /* handle epilogue */
       TextCode.add("\n; === epilogue ===");
	   TextCode.add("ret i32 0");
       TextCode.add("}");
    }
    
    
    /* Generate a new label */
    String newLabel()
    {
       labelCount ++;
       return (new String("L")) + Integer.toString(labelCount);
    } 

    int strCount =0;
    String newStr()
    {
       strCount++;
       return (new String("str")) + Integer.toString(strCount);
    } 
    
    public List<String> getTextCode()
    {
       return TextCode;
    }
}

program: (VOID|INT) MAIN '(' ')'
        {
           /* Output function prologue */
           prologue();
        }
        '{' 
           declarations
           statements
        '}'
        {
	    if (TRACEON)
	      System.out.println("VOID MAIN () {declarations statements}");

           /* output function epilogue */	  
           epilogue();
        }
        ;


declarations: type ID ';' declarations
        {
           if (TRACEON)
              System.out.println("declarations: type Identifier : declarations");

           if (symtab.containsKey($ID.text)) {
              // variable re-declared.
              System.out.println("Type Error: " + 
                                  $ID.getLine() + 
                                 ": Redeclared identifier.");
              System.exit(0);
           }
                 
           /* Add ID and its info into the symbol table. */
	       Info the_entry = new Info();
		   the_entry.theType = $type.attr_type;
		   the_entry.theVar.varIndex = varCount;
		   varCount ++;
		   symtab.put($ID.text, the_entry);
           // issue the instruction.
		   // Ex: \%a = alloca i32, align 4
           if ($type.attr_type == Type.INT) { 
              TextCode.add("\%t" + the_entry.theVar.varIndex + " = alloca i32, align 4");
           }
        }
        | type ID '=' pre_logic_expression ';'  
		{ 
		if (TRACEON)
              System.out.println("declarations: type Identifier : declarations");

           if (symtab.containsKey($ID.text)) {
              // variable re-declared.
              System.out.println("Type Error: " + 
                                  $ID.getLine() + 
                                 ": Redeclared identifier.");
              System.exit(0);
           }
                 
           /* Add ID and its info into the symbol table. */
	       Info the_entry = new Info();
		   the_entry.theType = $type.attr_type;
		   the_entry.theVar.varIndex = varCount;
		   varCount ++;
		   symtab.put($ID.text, the_entry);
           // issue the instruction.
		   // Ex: \%a = alloca i32, align 4
           if ($type.attr_type == Type.INT) { 
              TextCode.add("\%t" + the_entry.theVar.varIndex + " = alloca i32, align 4");
           }
		} declarations
        |;


type
returns [Type attr_type]
    : INT { if (TRACEON) System.out.println("type: INT"); $attr_type=Type.INT; }
	| SHORT { if (TRACEON) System.out.println("type: SHORT"); $attr_type=Type.SHORT; }
	| LONG { if (TRACEON) System.out.println("type: LONG"); $attr_type=Type.LONG; }
	| DOUBLE { if (TRACEON) System.out.println("type: DOUBLE"); $attr_type=Type.DOUBLE; }
    | CHAR { if (TRACEON) System.out.println("type: CHAR"); $attr_type=Type.CHAR; }
    | FLOAT {if (TRACEON) System.out.println("type: FLOAT"); $attr_type=Type.FLOAT; }
	;


statements:statement statements
          |
          ;


assign_stmt: ID '=' arith_expression
             {
                Info theRHS = $arith_expression.theInfo;
				Info theLHS = symtab.get($ID.text); 
		   
                if ((theLHS.theType == Type.INT) &&
                    (theRHS.theType == Type.INT)) {		   
                   // issue store insruction.
                   // Ex: store i32 \%tx, i32* \%ty
                   TextCode.add("store i32 \%t" + theRHS.theVar.varIndex + ", i32* \%t" + theLHS.theVar.varIndex);
				} else if ((theLHS.theType == Type.INT) &&
				    (theRHS.theType == Type.CONST_INT)) {
                   // issue store insruction.
                   // Ex: store i32 value, i32* \%ty
                   TextCode.add("store i32 " + theRHS.theVar.iValue + ", i32* \%t" + theLHS.theVar.varIndex);				
				}
			 }
             ;

		   
func_no_return_stmt: ID '(' argument ')'
                   ;


argument: arg (',' arg)*
        ;

arg: arith_expression
   | STRING_LITERAL
   ;
		   


pre_logic_expression
returns [Info theInfo]
@init {theInfo = new Info();}
                : a=pre_arith_expression { $theInfo=$a.theInfo; }
                 ( 	'||' pre_arith_expression
                	|'&&' pre_arith_expression
					|'!' pre_arith_expression
                 )*
                 ;

pre_arith_expression
returns [Info theInfo]
@init {theInfo = new Info();}
                : a= arith_expression { $theInfo=$a.theInfo; }
                 ( 	'>' b = arith_expression
                    {
                       // We need to do type checking first.
                       // ...
					  
                       // code generation.					   
                       if (($a.theInfo.theType == Type.INT) &&
                           ($b.theInfo.theType == Type.INT)) {
                           TextCode.add("\%t" + varCount + " = icmp sgt i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $b.theInfo.theVar.varIndex);
					   
					       // Update arith_expression's theInfo.
					       $theInfo.theType = Type.BOOL;
					       $theInfo.theVar.varIndex = varCount;
					       varCount ++;
                       } else if (($a.theInfo.theType == Type.INT) &&
					       ($b.theInfo.theType == Type.CONST_INT)) {
                           TextCode.add("\%t" + varCount + " = icmp sgt i32 \%t" + $theInfo.theVar.varIndex + ", " + $b.theInfo.theVar.iValue);
					   
					       // Update arith_expression's theInfo.
					       $theInfo.theType = Type.BOOL;
					       $theInfo.theVar.varIndex = varCount;
					       varCount ++;
                       }
					   else if (($a.theInfo.theType == Type.CONST_INT) &&
					       ($b.theInfo.theType == Type.INT)) {
                           TextCode.add("\%t" + varCount + " = icmp sgt i32 \%t" + $theInfo.theVar.iValue + ", " + $b.theInfo.theVar.varIndex);
					   
					       // Update arith_expression's theInfo.
					       $theInfo.theType = Type.BOOL;
					       $theInfo.theVar.varIndex = varCount;
					       varCount ++;
                       }
					   else if (($a.theInfo.theType == Type.CONST_INT) &&
					       ($b.theInfo.theType == Type.CONST_INT)) {
                           TextCode.add("\%t" + varCount + " = icmp sgt i32 \%t" + $theInfo.theVar.iValue + ", " + $b.theInfo.theVar.iValue);
					   
					       // Update arith_expression's theInfo.
					       $theInfo.theType = Type.BOOL;
					       $theInfo.theVar.varIndex = varCount;
					       varCount ++;
                       }
                    }
                 | '<' b = arith_expression
                    {
                       // We need to do type checking first.
                       // ...
					  
                       // code generation.					   
                       if (($a.theInfo.theType == Type.INT) &&
                           ($b.theInfo.theType == Type.INT)) {
                           TextCode.add("\%t" + varCount + " = icmp slt i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $b.theInfo.theVar.varIndex);
					   
					       // Update arith_expression's theInfo.
					       $theInfo.theType = Type.BOOL;
					       $theInfo.theVar.varIndex = varCount;
					       varCount ++;
                       } else if (($a.theInfo.theType == Type.INT) &&
					       ($b.theInfo.theType == Type.CONST_INT)) {
                           TextCode.add("\%t" + varCount + " = icmp slt i32 \%t" + $theInfo.theVar.varIndex + ", " + $b.theInfo.theVar.iValue);
					   
					       // Update arith_expression's theInfo.
					       $theInfo.theType = Type.BOOL;
					       $theInfo.theVar.varIndex = varCount;
					       varCount ++;
                       }
					   else if (($a.theInfo.theType == Type.CONST_INT) &&
					       ($b.theInfo.theType == Type.INT)) {
                           TextCode.add("\%t" + varCount + " = icmp slt i32 \%t" + $theInfo.theVar.iValue + ", " + $b.theInfo.theVar.varIndex);
					   
					       // Update arith_expression's theInfo.
					       $theInfo.theType = Type.BOOL;
					       $theInfo.theVar.varIndex = varCount;
					       varCount ++;
                       }
					   else if (($a.theInfo.theType == Type.CONST_INT) &&
					       ($b.theInfo.theType == Type.CONST_INT)) {
                           TextCode.add("\%t" + varCount + " = icmp slt i32 \%t" + $theInfo.theVar.iValue + ", " + $b.theInfo.theVar.iValue);
					   
					       // Update arith_expression's theInfo.
					       $theInfo.theType = Type.BOOL;
					       $theInfo.theVar.varIndex = varCount;
					       varCount ++;
                       }
                    }
				| '==' b = arith_expression
                    {
                       // We need to do type checking first.
                       // ...
					  
                       // code generation.					   
                       if (($a.theInfo.theType == Type.INT) &&
                           ($b.theInfo.theType == Type.INT)) {
                           TextCode.add("\%t" + varCount + " = icmp eq i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $b.theInfo.theVar.varIndex);
					   
					       // Update arith_expression's theInfo.
					       $theInfo.theType = Type.BOOL;
					       $theInfo.theVar.varIndex = varCount;
					       varCount ++;
                       } else if (($a.theInfo.theType == Type.INT) &&
					       ($b.theInfo.theType == Type.CONST_INT)) {
                           TextCode.add("\%t" + varCount + " = icmp eq i32 \%t" + $theInfo.theVar.varIndex + ", " + $b.theInfo.theVar.iValue);
					   
					       // Update arith_expression's theInfo.
					       $theInfo.theType = Type.BOOL;
					       $theInfo.theVar.varIndex = varCount;
					       varCount ++;
                       }
					   else if (($a.theInfo.theType == Type.CONST_INT) &&
					       ($b.theInfo.theType == Type.INT)) {
                           TextCode.add("\%t" + varCount + " = icmp eq i32 \%t" + $theInfo.theVar.iValue + ", " + $b.theInfo.theVar.varIndex);
					   
					       // Update arith_expression's theInfo.
					       $theInfo.theType = Type.BOOL;
					       $theInfo.theVar.varIndex = varCount;
					       varCount ++;
                       }
					   else if (($a.theInfo.theType == Type.CONST_INT) &&
					       ($b.theInfo.theType == Type.CONST_INT)) {
                           TextCode.add("\%t" + varCount + " = icmp eq i32 \%t" + $theInfo.theVar.iValue + ", " + $b.theInfo.theVar.iValue);
					   
					       // Update arith_expression's theInfo.
					       $theInfo.theType = Type.BOOL;
					       $theInfo.theVar.varIndex = varCount;
					       varCount ++;
                       }
                    }
				| '<=' b = arith_expression
                    {
                       // We need to do type checking first.
                       // ...
					  
                       // code generation.					   
                       if (($a.theInfo.theType == Type.INT) &&
                           ($b.theInfo.theType == Type.INT)) {
                           TextCode.add("\%t" + varCount + " = icmp sle i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $b.theInfo.theVar.varIndex);
					   
					       // Update arith_expression's theInfo.
					       $theInfo.theType = Type.BOOL;
					       $theInfo.theVar.varIndex = varCount;
					       varCount ++;
                       } else if (($a.theInfo.theType == Type.INT) &&
					       ($b.theInfo.theType == Type.CONST_INT)) {
                           TextCode.add("\%t" + varCount + " = icmp sle i32 \%t" + $theInfo.theVar.varIndex + ", " + $b.theInfo.theVar.iValue);
					   
					       // Update arith_expression's theInfo.
					       $theInfo.theType = Type.BOOL;
					       $theInfo.theVar.varIndex = varCount;
					       varCount ++;
                       }
					   else if (($a.theInfo.theType == Type.CONST_INT) &&
					       ($b.theInfo.theType == Type.INT)) {
                           TextCode.add("\%t" + varCount + " = icmp sle i32 \%t" + $theInfo.theVar.iValue + ", " + $b.theInfo.theVar.varIndex);
					   
					       // Update arith_expression's theInfo.
					       $theInfo.theType = Type.BOOL;
					       $theInfo.theVar.varIndex = varCount;
					       varCount ++;
                       }
					   else if (($a.theInfo.theType == Type.CONST_INT) &&
					       ($b.theInfo.theType == Type.CONST_INT)) {
                           TextCode.add("\%t" + varCount + " = icmp sle i32 \%t" + $theInfo.theVar.iValue + ", " + $b.theInfo.theVar.iValue);
					   
					       // Update arith_expression's theInfo.
					       $theInfo.theType = Type.BOOL;
					       $theInfo.theVar.varIndex = varCount;
					       varCount ++;
                       }
                    }
				| '>=' b = arith_expression
                    {
                       // We need to do type checking first.
                       // ...
					  
                       // code generation.					   
                       if (($a.theInfo.theType == Type.INT) &&
                           ($b.theInfo.theType == Type.INT)) {
                           TextCode.add("\%t" + varCount + " = icmp sge i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $b.theInfo.theVar.varIndex);
					   
					       // Update arith_expression's theInfo.
					       $theInfo.theType = Type.BOOL;
					       $theInfo.theVar.varIndex = varCount;
					       varCount ++;
                       } else if (($a.theInfo.theType == Type.INT) &&
					       ($b.theInfo.theType == Type.CONST_INT)) {
                           TextCode.add("\%t" + varCount + " = icmp sge i32 \%t" + $theInfo.theVar.varIndex + ", " + $b.theInfo.theVar.iValue);
					   
					       // Update arith_expression's theInfo.
					       $theInfo.theType = Type.BOOL;
					       $theInfo.theVar.varIndex = varCount;
					       varCount ++;
                       }
					   else if (($a.theInfo.theType == Type.CONST_INT) &&
					       ($b.theInfo.theType == Type.INT)) {
                           TextCode.add("\%t" + varCount + " = icmp sge i32 \%t" + $theInfo.theVar.iValue + ", " + $b.theInfo.theVar.varIndex);
					   
					       // Update arith_expression's theInfo.
					       $theInfo.theType = Type.BOOL;
					       $theInfo.theVar.varIndex = varCount;
					       varCount ++;
                       }
					   else if (($a.theInfo.theType == Type.CONST_INT) &&
					       ($b.theInfo.theType == Type.CONST_INT)) {
                           TextCode.add("\%t" + varCount + " = icmp sge i32 \%t" + $theInfo.theVar.iValue + ", " + $b.theInfo.theVar.iValue);
					   
					       // Update arith_expression's theInfo.
					       $theInfo.theType = Type.BOOL;
					       $theInfo.theVar.varIndex = varCount;
					       varCount ++;
                       }
                    }
					| '!=' b = arith_expression
                    {
                       // We need to do type checking first.
                       // ...
					  
                       // code generation.					   
                       if (($a.theInfo.theType == Type.INT) &&
                           ($b.theInfo.theType == Type.INT)) {
                           TextCode.add("\%t" + varCount + " = icmp ne i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $b.theInfo.theVar.varIndex);
					   
					       // Update arith_expression's theInfo.
					       $theInfo.theType = Type.BOOL;
					       $theInfo.theVar.varIndex = varCount;
					       varCount ++;
                       } else if (($a.theInfo.theType == Type.INT) &&
					       ($b.theInfo.theType == Type.CONST_INT)) {
                           TextCode.add("\%t" + varCount + " = icmp ne i32 \%t" + $theInfo.theVar.varIndex + ", " + $b.theInfo.theVar.iValue);
					   
					       // Update arith_expression's theInfo.
					       $theInfo.theType = Type.BOOL;
					       $theInfo.theVar.varIndex = varCount;
					       varCount ++;
                       }
					   else if (($a.theInfo.theType == Type.CONST_INT) &&
					       ($b.theInfo.theType == Type.INT)) {
                           TextCode.add("\%t" + varCount + " = icmp ne i32 \%t" + $theInfo.theVar.iValue + ", " + $b.theInfo.theVar.varIndex);
					   
					       // Update arith_expression's theInfo.
					       $theInfo.theType = Type.BOOL;
					       $theInfo.theVar.varIndex = varCount;
					       varCount ++;
                       }
					   else if (($a.theInfo.theType == Type.CONST_INT) &&
					       ($b.theInfo.theType == Type.CONST_INT)) {
                           TextCode.add("\%t" + varCount + " = icmp ne i32 \%t" + $theInfo.theVar.iValue + ", " + $b.theInfo.theVar.iValue);
					   
					       // Update arith_expression's theInfo.
					       $theInfo.theType = Type.BOOL;
					       $theInfo.theVar.varIndex = varCount;
					       varCount ++;
                       }
                    }
                 )*
                 ;

arith_expression
returns [Info theInfo]
@init {theInfo = new Info();}
                : a=  multExpr{ $theInfo=$a.theInfo; }
                 ( 	'+' b = multExpr
                    {
                       // We need to do type checking first.
                       // ...
					  
                       // code generation.					   
                       if (($a.theInfo.theType == Type.INT) &&
                           ($b.theInfo.theType == Type.INT)) {
                           TextCode.add("\%t" + varCount + " = add nsw i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $b.theInfo.theVar.varIndex);
					   
					       // Update arith_expression's theInfo.
					       $theInfo.theType = Type.INT;
					       $theInfo.theVar.varIndex = varCount;
					       varCount ++;
                       } else if (($a.theInfo.theType == Type.INT) &&
					       ($b.theInfo.theType == Type.CONST_INT)) {
                           TextCode.add("\%t" + varCount + " = add nsw i32 \%t" + $theInfo.theVar.varIndex + ", " + $b.theInfo.theVar.iValue);
					   
					       // Update arith_expression's theInfo.
					       $theInfo.theType = Type.INT;
					       $theInfo.theVar.varIndex = varCount;
					       varCount ++;
                       }
					   else if (($a.theInfo.theType == Type.CONST_INT) &&
					       ($b.theInfo.theType == Type.INT)) {
                           TextCode.add("\%t" + varCount + " = add nsw i32 \%t" + $theInfo.theVar.iValue + ", " + $b.theInfo.theVar.varIndex);
					   
					       // Update arith_expression's theInfo.
					       $theInfo.theType = Type.INT;
					       $theInfo.theVar.varIndex = varCount;
					       varCount ++;
                       }
					   else if (($a.theInfo.theType == Type.CONST_INT) &&
					       ($b.theInfo.theType == Type.CONST_INT)) {
                           TextCode.add("\%t" + varCount + " = add nsw i32 \%t" + $theInfo.theVar.iValue + ", " + $b.theInfo.theVar.iValue);
					   
					       // Update arith_expression's theInfo.
					       $theInfo.theType = Type.INT;
					       $theInfo.theVar.varIndex = varCount;
					       varCount ++;
                       }
                    }
                 | '-' c = multExpr
                    {
                       // We need to do type checking first.
                       // ...
					  
                       // code generation.					   
                       if (($a.theInfo.theType == Type.INT) &&
                           ($b.theInfo.theType == Type.INT)) {
                           TextCode.add("\%t" + varCount + " = sub nsw i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $b.theInfo.theVar.varIndex);
					   
					       // Update arith_expression's theInfo.
					       $theInfo.theType = Type.INT;
					       $theInfo.theVar.varIndex = varCount;
					       varCount ++;
                       } else if (($a.theInfo.theType == Type.INT) &&
					       ($b.theInfo.theType == Type.CONST_INT)) {
                           TextCode.add("\%t" + varCount + " = sub nsw i32 \%t" + $theInfo.theVar.varIndex + ", " + $b.theInfo.theVar.iValue);
					   
					       // Update arith_expression's theInfo.
					       $theInfo.theType = Type.INT;
					       $theInfo.theVar.varIndex = varCount;
					       varCount ++;
                       }
					   else if (($a.theInfo.theType == Type.CONST_INT) &&
					       ($b.theInfo.theType == Type.INT)) {
                           TextCode.add("\%t" + varCount + " = sub nsw i32 \%t" + $theInfo.theVar.iValue + ", " + $c.theInfo.theVar.varIndex);
					   
					       // Update arith_expression's theInfo.
					       $theInfo.theType = Type.INT;
					       $theInfo.theVar.varIndex = varCount;
					       varCount ++;
                       }
					   else if (($a.theInfo.theType == Type.CONST_INT) &&
					       ($b.theInfo.theType == Type.CONST_INT)) {
                           TextCode.add("\%t" + varCount + " = sub nsw i32 \%t" + $theInfo.theVar.iValue + ", " + $c.theInfo.theVar.iValue);
					   
					       // Update arith_expression's theInfo.
					       $theInfo.theType = Type.INT;
					       $theInfo.theVar.varIndex = varCount;
					       varCount ++;
                       }
                    }
                 )*
                 ;

multExpr
returns [Info theInfo]
@init {theInfo = new Info();}
          : a=signExpr { $theInfo=$a.theInfo; }
          ( '*' b=signExpr
		  {
			// We need to do type checking first.
			// ...
			
			// code generation.					   
			if (($a.theInfo.theType == Type.INT) &&
				($b.theInfo.theType == Type.INT)) {
				TextCode.add("\%t" + varCount + " = mul nsw i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $b.theInfo.theVar.varIndex);
			
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.INT;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
			} else if (($a.theInfo.theType == Type.INT) &&
				($b.theInfo.theType == Type.CONST_INT)) {
				TextCode.add("\%t" + varCount + " = mul nsw i32 \%t" + $theInfo.theVar.varIndex + ", " + $b.theInfo.theVar.iValue);
			
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.INT;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
			}
			else if (($a.theInfo.theType == Type.CONST_INT) &&
				($b.theInfo.theType == Type.INT)) {
				TextCode.add("\%t" + varCount + " = mul nsw i32 \%t" + $theInfo.theVar.iValue + ", " + $b.theInfo.theVar.varIndex);
			
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.INT;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
			}
			else if (($a.theInfo.theType == Type.CONST_INT) &&
				($b.theInfo.theType == Type.CONST_INT)) {
				TextCode.add("\%t" + varCount + " = mul nsw i32 \%t" + $theInfo.theVar.iValue + ", " + $b.theInfo.theVar.iValue);
			
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.INT;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
			}                       
        }
          | '/' c=signExpr
		  {
			// We need to do type checking first.
			// ...
			
			// code generation.					   
			if (($a.theInfo.theType == Type.INT) &&
				($c.theInfo.theType == Type.INT)) {
				TextCode.add("\%t" + varCount + " = sdiv i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $c.theInfo.theVar.varIndex);
			
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.INT;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
			} else if (($a.theInfo.theType == Type.INT) &&
				($c.theInfo.theType == Type.CONST_INT)) {
				TextCode.add("\%t" + varCount + " = sdiv i32 \%t" + $theInfo.theVar.varIndex + ", " + $c.theInfo.theVar.iValue);
			
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.INT;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
			}
			else if (($a.theInfo.theType == Type.CONST_INT) &&
				($c.theInfo.theType == Type.INT)) {
				TextCode.add("\%t" + varCount + " = sdiv i32 \%t" + $theInfo.theVar.iValue + ", " + $c.theInfo.theVar.varIndex);
			
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.INT;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
			}
			else if (($a.theInfo.theType == Type.CONST_INT) &&
				($c.theInfo.theType == Type.CONST_INT)) {
				TextCode.add("\%t" + varCount + " = sdiv i32 \%t" + $theInfo.theVar.iValue + ", " + $c.theInfo.theVar.iValue);
			
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.INT;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
			}                       
        }
		| '%' d=signExpr
		  {
			// We need to do type checking first.
			// ...
			
			// code generation.					   
			if (($a.theInfo.theType == Type.INT) &&
				($d.theInfo.theType == Type.INT)) {
				TextCode.add("\%t" + varCount + " = srem i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $d.theInfo.theVar.varIndex);
			
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.INT;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
			} else if (($a.theInfo.theType == Type.INT) &&
				($d.theInfo.theType == Type.CONST_INT)) {
				TextCode.add("\%t" + varCount + " = srem i32 \%t" + $theInfo.theVar.varIndex + ", " + $d.theInfo.theVar.iValue);
			
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.INT;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
			}
			else if (($a.theInfo.theType == Type.CONST_INT) &&
				($d.theInfo.theType == Type.INT)) {
				TextCode.add("\%t" + varCount + " = srem i32 \%t" + $theInfo.theVar.iValue + ", " + $d.theInfo.theVar.varIndex);
			
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.INT;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
			}
			else if (($a.theInfo.theType == Type.CONST_INT) &&
				($d.theInfo.theType == Type.CONST_INT)) {
				TextCode.add("\%t" + varCount + " = srem i32 \%t" + $theInfo.theVar.iValue + ", " + $d.theInfo.theVar.iValue);
			
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.INT;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
			}                       
        }
	  )*
	  ;

signExpr
returns [Info theInfo]
@init {theInfo = new Info();}
        : a=primaryExpr { $theInfo=$a.theInfo; } 
        | '-' primaryExpr
	;
		  
primaryExpr
returns [Info theInfo]
@init {theInfo = new Info();}
           : DEC_NUM
	     	{
				$theInfo.theType = Type.CONST_INT;
				$theInfo.theVar.iValue = Integer.parseInt($DEC_NUM.text);
        	}
           | FLOAT_NUM
			{
				$theInfo.theType = Type.CONST_INT;
				$theInfo.theVar.iValue = Integer.parseInt($FLOAT_NUM.text);
         	}
           | ID
            {
                // get type information from symtab.
                Type the_type = symtab.get($ID.text).theType;
				$theInfo.theType = the_type;

                // get variable index from symtab.
                int vIndex = symtab.get($ID.text).theVar.varIndex;
				
                switch (the_type) {
                case INT: 
						// get a new temporary variable and
						// load the variable into the temporary variable.
						
						// Ex: \%tx = load i32, i32* \%ty.
						TextCode.add("\%t" + varCount + "=load i32, i32* \%t" + vIndex);
						
						// Now, Identifier's value is at the temporary variable \%t[varCount].
						// Therefore, update it.
						$theInfo.theVar.varIndex = varCount;
						varCount ++;
						break;
                case SHORT:
						break;
				case LONG:
						break;
				case DOUBLE:
						break;
				case FLOAT:
                        break;
                case CHAR:
                        break;
                }
            }
	   		| ID '++'
	   		{
                // get type information from symtab.
                Type the_type = symtab.get($ID.text).theType;
				$theInfo.theType = the_type;

                // get variable index from symtab.
                int vIndex = symtab.get($ID.text).theVar.varIndex;
				
                switch (the_type) {
                case INT: 
						break;
                case SHORT:
						break;
				case LONG:
						break;
				case DOUBLE:
						break;
				case FLOAT:
                        break;
                case CHAR:
                        break;
                }
            }
			| ID '--'
	   		{
                // get type information from symtab.
                Type the_type = symtab.get($ID.text).theType;
				$theInfo.theType = the_type;

                // get variable index from symtab.
                int vIndex = symtab.get($ID.text).theVar.varIndex;
				
                switch (the_type) {
                case INT: 
						break;
                case SHORT:
						break;
				case LONG:
						break;
				case DOUBLE:
						break;
				case FLOAT:
                        break;
                case CHAR:
                        break;
                }
            }
			
			| '(' pre_logic_expression ')' {$theInfo = $pre_logic_expression.theInfo;}
    	;



statement: assign_stmt ';'
	| if_stmt
	// | func_no_return_stmt ';'
	| for_stmt
	| func_stmt
	| return_stmt
	;

func_stmt: 
			SCANF '('STRING_LITERAL ',' '&'  ID(',' '&'ID)?   ')' ';'
			| PRINTF '('STRING_LITERAL (',' a =pre_logic_expression(',' b =pre_logic_expression)?)?   ')' ';'
			{
				String str = $STRING_LITERAL.text;
				str = str.substring(1, str.length()-1);
				int nCount=0;
				int len =str.length()+1;
				for(int i=0;i<str.length();i++){
					if(str.charAt(i)=='\\'){
						if(str.charAt(i+1)=='n'){
							str = str.substring(0, i+1)+ "0A" + str.substring(i+2,str.length());
							i=i+2;
							nCount =nCount+1;
						}
			
					}
				}
				str =str+ "\\00";
				len = len - nCount;
					
				String string = newStr();
				//str = str.replace("\\n","\%n");
				TextCode.add(1,"@"+string+"= private unnamed_addr constant ["+Integer.toString(len)+" x i8] c\""+str+"\"");
				
				if($a.theInfo == null){
					//System.out.println(str);
					TextCode.add("call i32 (i8*, ...) @printf(i8* getelementptr inbounds (["+Integer.toString(len)+" x i8], ["+Integer.toString(len)+" x i8]* @"+string+", i64 0, i64 0))");
							
				}else if($b.theInfo == null ){
					if($a.theInfo.theType == Type.INT)
						TextCode.add("call i32 (i8*, ...) @printf(i8* getelementptr inbounds (["+Integer.toString(len)+" x i8], ["+Integer.toString(len)+" x i8]* @"+string+", i64 0, i64 0),i32 \%t"+$a.theInfo.theVar.varIndex+")");			   
							if($a.theInfo.theType == Type.CONST_INT)
						TextCode.add("call i32 (i8*, ...) @printf(i8* getelementptr inbounds (["+Integer.toString(len)+" x i8], ["+Integer.toString(len)+" x i8]* @"+string+", i64 0, i64 0),i32 "+$a.theInfo.theVar.iValue+")");	
					
				}else{
					if($a.theInfo.theType == Type.INT && $b.theInfo.theType == Type.INT )
						TextCode.add("call i32 (i8*, ...) @printf(i8* getelementptr inbounds (["+Integer.toString(len)+" x i8], ["+Integer.toString(len)+" x i8]* @"+string+", i64 0, i64 0),i32 \%t"+$a.theInfo.theVar.varIndex+",i32 \%t"+$b.theInfo.theVar.varIndex+")");			   
							if($a.theInfo.theType == Type.INT && $b.theInfo.theType == Type.CONST_INT )
						TextCode.add("call i32 (i8*, ...) @printf(i8* getelementptr inbounds (["+Integer.toString(len)+" x i8], ["+Integer.toString(len)+" x i8]* @"+string+", i64 0, i64 0),i32 \%t"+$a.theInfo.theVar.varIndex+",i32 "+$b.theInfo.theVar.iValue+")");		
					if($a.theInfo.theType == Type.CONST_INT && $b.theInfo.theType == Type.INT )
						TextCode.add("call i32 (i8*, ...) @printf(i8* getelementptr inbounds (["+Integer.toString(len)+" x i8], ["+Integer.toString(len)+" x i8]* @"+string+", i64 0, i64 0),i32 "+$a.theInfo.theVar.iValue+",i32 \%t"+$b.theInfo.theVar.varIndex+")");			   	   			
					if($a.theInfo.theType == Type.CONST_INT && $b.theInfo.theType == Type.CONST_INT )
						TextCode.add("call i32 (i8*, ...) @printf(i8* getelementptr inbounds (["+Integer.toString(len)+" x i8], ["+Integer.toString(len)+" x i8]* @"+string+", i64 0, i64 0),i32 "+$a.theInfo.theVar.iValue+",i32 "+$b.theInfo.theVar.iValue+")");			   	   			
				}
			};

for_stmt: FOR '(' assign_stmt ';'
                  pre_arith_expression ';'
                  assign_stmt
              ')'
                  block_stmt
        ;
		 
/*
	cond = icmp sgt i32 %t3, 0 ; a > 0?
	br i1 %cond, label %Ltrue, label %Lfalse
	Ltrue: ; If-then part
	store i32 0, i32* %t2, align 4 ; b = 0
	br label %Lend
	Lfalse: ; If-else part
	%t5 = load i32, i32* %t1, align 4 ; load a to %t5
	%t6 = add nsw i32 %t5, 2 ; %t6 = a + 2
	store i32 %t6, i32* %t2, align 4 ; store %t6 to b
	br label %Lend
 */
if_stmt
scope {
String myEndLabel;
}
            : 
			{
				$if_stmt::myEndLabel = newLabel();
			}
			t1=if_then_stmt[$if_stmt::myEndLabel] {
				
			} {
				TextCode.add("br label \%" + $t1.retFalseLabel);
				TextCode.add( $t1.retFalseLabel + ":");
			} if_else_stmt 
			{ 
				TextCode.add("br label \%" + $if_stmt::myEndLabel);
				TextCode.add( $if_stmt::myEndLabel + ":");
			 }
			| t2=if_then_stmt  [$if_stmt::myEndLabel] {
				TextCode.add("br label \%" + $t2.retFalseLabel);
				TextCode.add($t2.retFalseLabel + ":");				
				TextCode.add( $if_stmt::myEndLabel + ":");
				TextCode.add("br label \%" + $if_stmt::myEndLabel);
			}
            ;

	   

if_then_stmt [String endLabel] returns [String retFalseLabel] 
scope {
	String trueLabel;
}
            : IF '(' pre_arith_expression ')' {
				$if_then_stmt::trueLabel = newLabel();
				$retFalseLabel = newLabel();
				TextCode.add("br i1 \%t" + $pre_arith_expression.theInfo.theVar.varIndex + ", label \%" + $if_then_stmt::trueLabel + ", label \%" + $retFalseLabel + "");
				TextCode.add("br label  \%" + $if_then_stmt::trueLabel);
				TextCode.add($if_then_stmt::trueLabel + ": ;");
			} block_stmt {
				TextCode.add("br label  \%" + $endLabel);
				
			} 
            ;


if_else_stmt
            : ELSE block_stmt
            |
            ;

return_stmt
			: RETURN arith_expression ';'
				{
					TextCode.add("ret i32 " + $arith_expression.theInfo.theVar.iValue);
				}
			; 
				  
block_stmt: '{' statements '}'
	  ;

		   
/* description of the tokens */

/*----------------------*/
/*   Reserved Keywords  */
/*----------------------*/
FLOAT:'float';
DOUBLE : 'double';
INT:'int';
SHORT : 'short';
LONG : 'long';
CHAR: 'char';
PRINTF: 'printf';
SCANF : 'scanf';
MAIN: 'main';
VOID: 'void';
WHILE: 'while';
IF: 'if';
ELSE: 'else';
FOR: 'for';
SWITCH : 'switch';
CASE : 'case';
DEFAULT : 'default';
SIZEOF : 'sizeof';
INCLUDE : 'include';
BREAK : 'break';
RETURN: 'return';

/*----------------------*/
/*  Compound Operators  */
/*----------------------*/
ADD : '+';
SUB : '-';
DIV : '/';
MUL : '*';
MOD : '%';

EQ_OP : '==';
GT_OP : '>';
LT_OP : '<';
LE_OP : '<=';
GE_OP : '>=';
NE_OP : '!=';

PP_OP : '++';
MM_OP : '--'; 

AND : '&&';
OR : '||';


/*----------------------*/
/*        Symbol        */
/*----------------------*/
ASSIGN_OP : '=';
COLON : ':';
COMMA : ',';
SEMICOLON : ';';
QUESTION : '?';
LEFT_PAREM : '(';
RIGHT_PAREM : ')';
LEFT_BRACKET : '[';
RIGHT_BRACKET : ']';
LEFT_BRACE : '{';
RIGHT_BRACE : '}';

/*string */
STRING_LITERAL : '"' ( EscapeSequence | ~('\\'|'"') )* '"';
fragment EscapeSequence : '\\' ('b'|'t'|'n'|'f'|'r'|'\"'|'\''|'\\');
Char : '\'' ('\\\''|~'\'') '\'';

/*NUMBER*/
DEC_NUM : (DIGIT)+;
FLOAT_NUM: FLOAT_NUM1 | FLOAT_NUM2;
fragment FLOAT_NUM1: (DIGIT)+'.'(DIGIT)*;
fragment FLOAT_NUM2: '.'(DIGIT)+;

fragment LETTER : 'a'..'z' | 'A'..'Z' | '_';
fragment DIGIT : '0'..'9';

ID:(LETTER)(LETTER | DIGIT)*;

// RelationOP: EQ_OP | NE_OP | GT_OP | LT_OP | LE_OP;

WHITE_SPACE : (' '|'\r'|'\t')+ {$channel=HIDDEN;};
NEW_LINE    : '\n' {$channel=HIDDEN;};

/*----------------------*/
/*       Comments       */
/*----------------------*/
COMMENT_1 : '//'(.)*'\n' {$channel=HIDDEN;};
COMMENT_2 : '/*' (options{greedy=false;}: .)* '*/' {$channel=HIDDEN;};



