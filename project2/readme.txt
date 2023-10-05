資工三 409410114 周述君

環境:
antlr-3.5.3-complete-no-st3.jar

生成parser:
java -cp ./antlr-3.5.3-complete-no-st3.jar org.antlr.Tool myparser.g生成myparserLexer.java、myparserParser.java和myparser.tokens
編譯.java
javac -cp ./antlr-3.5.3-complete-no-st3.jar:. *.java
執行parser
java -cp ./antlr-3.5.3-complete-no-st3.jar:. testParser 
or
make指令

測試
java -cp ./antlr-3.5.3-complete-no-st3.jar:. testParser test1.c
java -cp ./antlr-3.5.3-complete-no-st3.jar:. testParser test2.c
java -cp ./antlr-3.5.3-complete-no-st3.jar:. testParser test3.c
