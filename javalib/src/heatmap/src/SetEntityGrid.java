import java.awt.*;
import java.awt.geom.Rectangle2D;
import java.awt.image.BufferedImage;
import java.io.File;
import java.util.ArrayList;
import java.util.Iterator;

import javax.imageio.ImageIO;
import javax.swing.JApplet;

public class SetEntityGrid extends JApplet {
	
    private final static int GRID_HEIGHT = 400;
    private final static int GRID_WIDTH = 800;
    
    private ArrayList<Set> sets = null;
    private ArrayList<Entity> entities = null;
    
    public SetEntityGrid(Set newsets[]) {
    	
    	this.sets = new ArrayList<Set>();
    	this.entities = new ArrayList<Entity>();
    	
    	for (int i=0; i < newsets.length; i++) {
    		
    		// add to the sets list
    		sets.add(newsets[i]);
    		
    		// add the entities for this set that aren't already here
    		ArrayList<Entity> ents = newsets[i].getEntities();
    		Iterator<Entity> iter = ents.iterator();
    		while (iter.hasNext()) {
    			Entity newEnt = iter.next();
    			if (!this.entities.contains((Entity)newEnt)) {
    				this.entities.add((Entity)newEnt);
    			}
    		}   		
    	}	
    	
    }
    
    public void init() {
        setBackground(Color.white);
    }
    
    public void makeGif() {
    	
    	BufferedImage img = null;
    	try {
    		File file = new File("/Users/epaull/Desktop/test.gif");
    		file.createNewFile();
    	    BufferedImage image =
    	        new BufferedImage(GRID_WIDTH, GRID_HEIGHT, BufferedImage.TYPE_INT_RGB);
    	    Graphics2D g2 = (Graphics2D)image.createGraphics();
    	    paintGrid(g2);
    	    ImageIO.write(image, "gif", file);
    		
    	} catch (Exception e) {
    		
    		System.out.print("error!");
    	}
  
    }
	public void paintRect(Graphics g) {
		Graphics2D g2 = (Graphics2D) g;
		 g2.setBackground(getBackground());
		 int height = GRID_HEIGHT;
		 int width = GRID_WIDTH;
		 g2.setRenderingHint(RenderingHints.KEY_ANTIALIASING,
	                            RenderingHints.VALUE_ANTIALIAS_ON);

		 // draw horizontal lines 
		 for (int i = 10; i < GRID_HEIGHT; i = i + 10) {
			 g2.drawLine(0, i, GRID_WIDTH, i);
		 }
		 // vertical lines
		 for (int i = 10; i < GRID_WIDTH; i = i + 10) {
			 g2.drawLine(i, 0, i, GRID_HEIGHT);
		 }
		 g2.drawRect(0, 0, GRID_WIDTH, GRID_HEIGHT);
	}
	
	public void paintGrid(Graphics g) {
		Graphics2D g2 = (Graphics2D) g;
		 //g2.setBackground(GetBackground());
		 int height = GRID_HEIGHT;
		 int width = GRID_WIDTH;
		 g2.setRenderingHint(RenderingHints.KEY_ANTIALIASING,
	                            RenderingHints.VALUE_ANTIALIAS_ON);

		 // math on size of cells
		 int numColumns = this.sets.size();
		 int numRows = this.entities.size();
		 int cellWidth = (int)(GRID_WIDTH / numColumns);
		 int cellHeight = (int)(GRID_HEIGHT / numRows);
		 
		 // set and entity iterators
		 Iterator<Set> setsIter = this.sets.iterator();
		 
		 int columnIndex = 0;
		 while (setsIter.hasNext()) {
			 // draw the column for this set
			 Set set = (Set)setsIter.next();
			 
			 // debug
			 g2.setColor(Color.GREEN);
			 g2.drawString("set"+set,columnIndex,0);
			 
			 
			 int rowIndex = 0;
			 Iterator<Entity> entityIter = this.entities.iterator();
			 while (entityIter.hasNext()) {
				 
				 Entity ent = entityIter.next();
			 
				 g2.setColor(Color.GREEN);
				 g2.drawString("entity"+ent,0,rowIndex);
			 
				 Rectangle2D rect = set.getRectForOverlap(columnIndex, rowIndex, cellWidth, cellHeight);
				 // set the color of the cell based on overlap
				 if (set.contains(ent)) {
					 g2.setColor(Color.RED);
				 } else {
					 g2.setColor(Color.BLACK);
				 }
				 rowIndex = rowIndex + cellHeight;
				 
				 // drawing steps
				 g2.fill(rect);
				 g2.draw(rect);
			 }
			 
			 columnIndex = columnIndex + cellWidth;			 
		 }

		 //g2.drawRect(0, 0, GRID_WIDTH, GRID_HEIGHT);
	}

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		
		int ids1[] = {114, 115, 116};
		int ids2[] = {114, 117, 250};
		int ids3[] = {114, 116, 130};
		Set set1 = new Set(ids1);
		Set set2 = new Set(ids2);
		Set set3 = new Set(ids3);
		Set thesesets[] = {set1, set2, set3};

		SetEntityGrid grid = new SetEntityGrid(thesesets);
		grid.init();
		grid.makeGif();
	}
}
