import java.awt.Color;
import java.awt.Graphics2D;
import java.util.ArrayList;
import java.util.Iterator;



public class Grid {
	ArrayList<Column> columns;
	
	public Grid() {
		this.columns = new ArrayList<Column>();
	}
	
	public void addColumn(Column column) {
		this.columns.add(column);
	}
	
	public void paintGrid(Graphics2D g2, Color memberColor, Color neutral, Color antiMemberColor) {
		Iterator<Column> colIter = columns.iterator();
		while (colIter.hasNext()) {
			colIter.next().paintColumn(g2, memberColor, neutral, antiMemberColor);
		}		
	}

}
