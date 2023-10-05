資工三 409410114 周述君

環境:
antlr-3.5.3-complete-no-st3.jar

生成parser:
java -cp ./antlr-3.5.3-complete-no-st3.jar org.antlr.Tool myChecker.g生成myCheckerLexer.java、myCheckerParser.java和myChecker.tokens
編譯.java
javac -cp ./antlr-3.5.3-complete-no-st3.jar:. *.java
執行parser
java -cp ./antlr-3.5.3-complete-no-st3.jar:. myChecker_test
or
make指令

測試
FILE=./test1.c make run
FILE=./test2.c make run
FILE=./test3.c make run

type mismatch會輸出operator左右兩邊的型態
test1.c、test2.c沒有錯誤test3.c會產生錯誤訊息(project3_v1.pdf)