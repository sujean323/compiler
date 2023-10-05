all:
	java -cp ./antlr-3.5.3-complete-no-st3.jar:. org.antlr.Tool myChecker.g
	javac -cp ./antlr-3.5.3-complete-no-st3.jar:. *.java

run:
	java -cp ./antlr-3.5.3-complete-no-st3.jar:. myChecker_test ${FILE}

clean:    
	rm -rf *.class
	rm -rf *.tokens
	rm -rf myCheckerLexer.java myCheckerParser.java
