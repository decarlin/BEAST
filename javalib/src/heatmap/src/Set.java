import java.awt.Rectangle;
import java.awt.geom.Rectangle2D;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.json.JSONArray;
import org.json.JSONObject;


public class Set {

	private String name;
	private ArrayList<Entity> entities;
	private HashMap<String, String> meta;
	
	public Set(String ids[]) {
		
		this.entities = new ArrayList<Entity>();
		
		for (int i = 0; i < ids.length; i++) {
			Entity ent = new Entity(ids[i]);
			this.entities.add(ent);
		}
	}
	
	public Set(String jsonText) throws Exception {
				
		this.entities = new ArrayList<Entity>();
		this.meta = new HashMap<String, String>();

		JSONArray arr1 = new JSONArray(jsonText);
		JSONObject jsonObj = arr1.getJSONObject(0);
		
		this.name = jsonObj.getString("_name");
		
		JSONObject elements = jsonObj.getJSONObject("_elements");
		Iterator<String> keys = elements.keys();

		while (keys.hasNext()) {
			this.entities.add(new Entity(keys.next()));
		}
		
		JSONObject metas = jsonObj.getJSONObject("_metadata");
		Iterator<String> metaKeys = metas.keys();

		while (metaKeys.hasNext()) {
			String key = metaKeys.next();
			this.meta.put(key, metas.getString(key));
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
		
		ArrayList<String> metas = (ArrayList<String>) this.meta.keySet();
		Iterator<String> metaIter = metas.iterator();
		newstr = newstr + "Metas: ";
		while (metaIter.hasNext()) {
			String key = metaIter.next();
			newstr = newstr + ":" + key + "-val-" + this.meta.get(key);
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
