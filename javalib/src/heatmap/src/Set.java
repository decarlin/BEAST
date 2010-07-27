import java.awt.Rectangle;
import java.awt.geom.Rectangle2D;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.regex.Matcher;
import java.util.regex.Pattern;


public class Set {

	private String name;
	private ArrayList<Entity> entities;
	
	public Set(String ids[]) {
		
		this.entities = new ArrayList<Entity>();
		
		for (int i = 0; i < ids.length; i++) {
			Entity ent = new Entity(ids[i]);
			this.entities.add(ent);
		}
	}
	
	public Set(String jsonText) throws Exception {
		Pattern p = Pattern.compile("\\{(.*)\\}");
		Matcher m = p.matcher(jsonText);
		if (!m.matches()) { 
				//
		}
		String core = m.group(1);

		
		Pattern pn = Pattern.compile(".*'_name':'(.*?)'.*");
		Matcher mn = pn.matcher(core);
		if (mn.matches()) {
			this.name = mn.group(1);
		}
		
		this.entities = new ArrayList<Entity>();
		
		Pattern pe = Pattern.compile(".*'_elements':\\{(.*?)\\}");
		Matcher me = pe.matcher(core);
		if (me.matches()) {
			String els = me.group(1);
			String ellist[] = els.split(",");
			Pattern pel = Pattern.compile("'(.*?)':.*");
			for (int i=0; i < ellist.length; i++) {
				Matcher mel = pel.matcher(ellist[i]);
				if (!mel.matches()) { throw new Exception("can't match" + core); }
				String elementName = mel.group(1);
				this.entities.add(new Entity(elementName));
			}
		}
		
	}
	
	
	public boolean contains(Entity entity) {
		
		if (this.entities.contains(entity)) {
			return true;
		}
		return false;
	}
	
	public ArrayList<Entity> getEntities() {
		return this.entities;
	}
	
	public String toString() {
		String newstr = new String("Elements: ");
		Iterator<Entity> iter = this.entities.iterator();
		while (iter.hasNext()) {
			newstr = newstr + ":" + ((Entity)iter.next()).toString();
		}
		return newstr;
	}
	
	public String getName() {
		return this.name;
	}
	
	public Rectangle2D getRectForOverlap(int xstart, int ystart, int width, int height) {
		 Rectangle2D rect = new Rectangle(xstart, ystart, width, height);
		 return (Rectangle2D)rect;
	}
	
}
