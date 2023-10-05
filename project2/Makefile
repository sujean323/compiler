run: myparser.g
	java -cp ./antlr-3.5.3-complete-no-st3.jar org.antlr.Tool myparser.g
	javac -cp ./antlr-3.5.3-complete-no-st3.jar *.java

clean:
	rm -rf *.class
	rm -rf *.tokens
	rm -rf myparserLexer.java myparserParser.java