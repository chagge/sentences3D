
import java.util.Collection;
import java.util.List;
import java.io.StringReader;
import java.io.PrintWriter;
import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;


import edu.stanford.nlp.process.TokenizerFactory;
import edu.stanford.nlp.process.CoreLabelTokenFactory;
import edu.stanford.nlp.process.DocumentPreprocessor;
import edu.stanford.nlp.process.PTBTokenizer;
import edu.stanford.nlp.ling.CoreLabel;
import edu.stanford.nlp.ling.Label;
import edu.stanford.nlp.ling.HasWord;
import edu.stanford.nlp.ling.Sentence;
import edu.stanford.nlp.trees.*;
import edu.stanford.nlp.parser.lexparser.LexicalizedParser;

class KC_Parser{
    private String[] sentences;
    private String[] dependencies;
    private String[] trees;
    private String[] tags;
    private LexicalizedParser lp;
    public KC_Parser(String sentence){
    	sentences = sentence.split("# ");
    	lp = LexicalizedParser.loadModel("edu/stanford/nlp/models/lexparser/englishPCFG.ser.gz");
    	TreebankLanguagePack tlp = new PennTreebankLanguagePack();
        GrammaticalStructureFactory gsf = tlp.grammaticalStructureFactory();
        int nsen = sentences.length;
        tags = new String[nsen];
        trees = new String[nsen];
        dependencies = new String[nsen];
        for(int isen = 1;isen < nsen;isen ++)
        {
        	String sent = sentences[isen];
        	sent = sent.replace("-", "_");
        	sent = sent.toLowerCase();
        	Tree parse = lp.parse(sent);
            GrammaticalStructure gs = gsf.newGrammaticalStructure(parse);
            List tdl = gs.typedDependenciesCCprocessed();
            tags[isen] = parse.taggedYield().toString(); // tag
            tags[isen] = tags[isen].replace("[", "");
            tags[isen] = tags[isen].replace("]", "");
            tags[isen] = tags[isen].replace(",","");
            trees[isen] = parse.pennString();
            //parse.pennPrint(fileout); //tree
            dependencies[isen] = tdl.toString();//dependency
            dependencies[isen] = dependencies[isen].replace("[", "");
            dependencies[isen] = dependencies[isen].replace("]", "");
            dependencies[isen] = dependencies[isen].replace(" ", "");
            dependencies[isen] = dependencies[isen].replace("),", ") ");
            //parse.clear();
        }
    }
    public String show_dependencies(){
    	String r = new String();
    	for(int i = 1; i < dependencies.length; i ++)
    	{
    		r = r + "#" + dependencies[i];
    	}
    	return r;
    }
    public String show_trees(){
    	String r = new String();
    	for(int i = 1; i < trees.length; i ++)
    	{
    		r = r + "#" + trees[i];
    	}
    	return r;
    }
    public String show_tags(){
    	String r = new String();
    	for(int i = 1; i < tags.length; i ++)
    	{
    		r = r + "#" + tags[i];
    	}
    	r = r.replace(" / ", " ");
    	return r;
    }
    
    public static void main(String[] args) {
        // load Parser;
        KC_Parser demo = new KC_Parser("# There are two people, a man and a woman, standing in a very large room that has two pillars that go to the ceiling");
        System.out.println(demo.show_dependencies());
        System.out.println(demo.show_trees());
        System.out.println(demo.show_tags());
    }
    
}
