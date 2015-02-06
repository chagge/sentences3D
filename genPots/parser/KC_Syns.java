import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;

import edu.mit.jwi.Dictionary;
import edu.mit.jwi.IDictionary;
import edu.mit.jwi.item.IIndexWord;
import edu.mit.jwi.item.ISynset;
import edu.mit.jwi.item.IWord;
import edu.mit.jwi.item.IWordID;
import edu.mit.jwi.item.POS;
import edu.mit.jwi.morph.WordnetStemmer;

public class KC_Syns{
	private String Word;
	private String Stem;
	private List<String> SynSet= new ArrayList<String>();
	
	public KC_Syns(String in, String root){
		Word = in;
		String wnhome = root;
		String path = wnhome + File.separator + "code/parser/dict"; URL url;
		try {
			url = new URL("file", null, path);
			// construct the dictionary object and open it
	        IDictionary dict = new Dictionary(url); 
			dict.open();
			getSynonyms(dict);
			dict.close();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

    private void getSynonyms(IDictionary dict){
    	//plural stemmer
		WordnetStemmer stemmer = new WordnetStemmer(dict);
		java.util.List<String> stems = stemmer.findStems(Word, POS.NOUN);
		if(stems.isEmpty()){
			Stem = Word.replace(" ", "_");
		}
		else
			Stem = stems.get(0);
		//find synonyms
		IIndexWord idxWord = dict.getIndexWord(Stem, POS.NOUN);
       	SynSet.add(Stem);
		if(idxWord == null)
			return;
    	//for(int i=0;i<idxWord.getWordIDs().size();i++){
        for(int i=0;i<1;i++){
    		IWordID wordID = idxWord.getWordIDs().get(i); // 1st meaning
           	IWord word = dict.getWord(wordID);
           	ISynset synset = word.getSynset();
           	// iterate over words associated with the synset
           	for(IWord w : synset.getWords()) {
           		String temp = w.getLemma();
           		if(!temp.equals(Stem))
           			SynSet.add(temp);
           	}
    	}
    }  
    public String ShowStem(){
    	return Stem;
    }
    public String ShowSynSet(){
    	String synset =  SynSet.toString();
    	synset = synset.replace("[", "");
    	synset = synset.replace("]", "");
    	synset = synset.replace(",","");
    	return synset;
    }
    public String GetStem(){
    	return Stem;
    }
    public List<String> GetSynSet(){
    	return SynSet;
    }
    public static void main(String[] args){
    	KC_Syns demo = new KC_Syns("kong chen", "/Users/data/sentences3D");
    	System.out.println(demo.ShowStem());
    	System.out.println(demo.ShowSynSet());
    }
}
