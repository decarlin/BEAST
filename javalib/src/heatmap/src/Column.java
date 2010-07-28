import java.awt.Color;
import java.awt.Graphics2D;
import java.util.ArrayList;
import java.util.Iterator;


public class Column {

	private double index;
	// order matters
	private ArrayList<Cell> cells;
	
	public Column(double columnIndex) {
		this.index = columnIndex;
		this.cells = new ArrayList<Cell>();
	}
	
	public void addCell(Cell cell) {
		this.cells.add(cell);
	}
	
	public void paintColumn(Graphics2D g2, Color memberColor, Color neutral, Color antiMemberColor) {
		Iterator<Cell> cellIter = this.cells.iterator();
		while (cellIter.hasNext()) {
			cellIter.next().drawCellToCanvas(g2, memberColor, neutral, antiMemberColor);			
		}
	}
	
}
