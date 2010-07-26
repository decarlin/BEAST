
public class Entity {
	
	private int value;
	
	public Entity(int i) {
		this.value = i;
	}
	
	public int getValue() {
		return this.value;
	}
	
	public boolean equals(Object e) {
		Entity ent = null;
		try {
			ent = (Entity)e;
		} catch (Exception ex) {
			//
		}
		if (ent.getValue() == this.getValue()) {
			return true;
		}
		return false;
	}
	
	public String toString() {
		Integer number = new Integer(this.value);
		return number.toString();
	}

}
