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
    
    public Set(JSONObject jsonObj) throws Exception {
                
        this.entities = new ArrayList<Entity>();
        this.meta = new HashMap<String, String>();

        this.name = jsonObj.getString("_name");
        
        JSONObject elements = jsonObj.getJSONObject("_elements");
        Iterator<String> keys = elements.keys();

        while (keys.hasNext()) {
            String entName = keys.next();
            this.entities.add(new Entity(entName));
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
    
    public int membershipValue(Entity entity) {
        if (!this.entities.contains(entity)) {
            return 0;
        }
        return 1;
        //return this.entities;
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
    
}
