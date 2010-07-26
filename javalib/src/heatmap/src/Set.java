import java.awt.Rectangle;
import java.awt.geom.Point2D;
import java.awt.geom.Rectangle2D;
import java.util.ArrayList;
import java.util.Iterator;


public class Set {

	private ArrayList<Entity> entities;
	
	public Set(int ids[]) {
		
		this.entities = new ArrayList<Entity>();
		
		for (int i = 0; i < ids.length; i++) {
			Entity ent = new Entity(ids[i]);
			this.entities.add(ent);
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
		String newstr = new String();
		Iterator<Entity> iter = this.entities.iterator();
		while (iter.hasNext()) {
			newstr = newstr + ((Entity)iter.next()).toString();
		}
		return newstr;
	}
	
	public Rectangle2D getRectForOverlap(int xstart, int ystart, int width, int height) {
		 Rectangle2D rect = new Rectangle(xstart, ystart, width, height);
		 return (Rectangle2D)rect;
	}

}
