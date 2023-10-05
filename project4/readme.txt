資工三 409410114 周述君

環境:
antlr-3.5.3-complete-no-st3.jar

-生成compiler
java -jar ./antlr-3.5.3-complete-no-st3.jar myCompiler.g
產生myCompilerLexer.java、myCompilerParser.java和myCompiler.tokens  
-編譯.java
javac -cp ./antlr-3.5.3-complete-no-st3.jar:. *.java
-執行parser
java -cp ./antlr-3.5.3-complete-no-st3.jar:. myCompiler_test
or
make指令

測試
FILE=./filename.c make run
or
java -cp ./antlr-3.5.3-complete-no-st3.jar:. myCompiler_test filename.c