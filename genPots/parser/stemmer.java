import java.io.File;
import java.io.IOException;
import java.net.URL;

import edu.mit.jwi.Dictionary;
import edu.mit.jwi.IDictionary;
import edu.mit.jwi.item.POS;
import edu.mit.jwi.morph.WordnetStemmer;

class stemmer{
	private String word;
	private String stem;
	public stemmer(String word_in, String root){
		word = word_in;
		String wnhome = root;
		String path = wnhome + File.separator + "code/parser/dict"; URL url;
		try {
			url = new URL("file", null, path);
			IDictionary dict = new Dictionary(url);
			dict.open();
			WordnetStemmer stemmer = new WordnetStemmer(dict);
			java.util.List<String> stems = stemmer.findStems(word, POS.NOUN);
			if(stems.isEmpty())
				stem = word.replace(" ", "_");
			else
				stem = stems.get(0);
			dict.close();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	public String ShowStem(){
		return stem;
	}
	public static void main(String[] args){
		stemmer s = new stemmer("kong chen", "/Users/data/sentences3D");
		System.out.println(s.ShowStem());
	}
}