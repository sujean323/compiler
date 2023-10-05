
all:
	java -cp ./antlr-3.5.3-complete-no-st3.jar:. org.antlr.Tool myCompiler.g
	javac -cp ./antlr-3.5.3-complete-no-st3.jar:. *.java

run:
	java -cp ./antlr-3.5.3-complete-no-st3.jar:. myCompiler_test ${FILE}


clean:    
	rm -rf *.class
	rm -rf *.tokens
	rm -rf myCompilerLexer.java myCompilerParser.java
