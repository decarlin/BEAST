
public class Entity {
	
	private String value;
	
	public Entity(String str) {
		this.value = str;
	}
	
	public String getValue() {
		return this.value;
	}
	
	public boolean equals(Object e) {
		Entity ent = null;
		try {
			ent = (Entity)e;
		} catch (Exception ex) {
			//
		}
		if (ent.getValue().compareTo(this.getValue()) == 0) {
			return true;
		}
		return false;
	}
	
	public String toString() {
		return value;
	}

}
