import java.awt.*;
import java.awt.geom.Rectangle2D;
import java.awt.image.BufferedImage;
import java.io.File;
import java.util.ArrayList;
import java.util.Iterator;

import javax.imageio.ImageIO;
import javax.swing.JApplet;

public class SetEntityGrid extends JApplet {
	
	private static Color background;
    private final static int GRID_HEIGHT = 400;
    private final static int GRID_WIDTH = 800;
    private final static int ROW_BORDER = 100;
    private final static int COLUMN_BORDER = 100;
    
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
    
    public void setBackground(Color c) {
    	background = c;
    }
    public Color getBackground() {
    	return this.background;
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

	public void paintGrid(Graphics g) {
		Graphics2D g2 = (Graphics2D) g;
		g2.setBackground(getBackground());

		g2.setRenderingHint(RenderingHints.KEY_ANTIALIASING,
	                            RenderingHints.VALUE_ANTIALIAS_ON);

		// math on size of cells
		int numColumns = this.sets.size();
		int numRows = this.entities.size();
		int cellWidth = (int)((GRID_WIDTH - ROW_BORDER) / numColumns);
		int cellHeight = (int)((GRID_HEIGHT - COLUMN_BORDER)/ numRows);		 
		
		
		// set and entity iterators
		Iterator<Set> setsIter = this.sets.iterator();
		 
		int columnIndex = COLUMN_BORDER;
		while (setsIter.hasNext()) {
			 // draw the column for this set
			Set set = (Set)setsIter.next();
			 
			// debug
			g2.setColor(Color.GREEN);
			g2.drawString(set.getName(), columnIndex + (cellWidth / 4), COLUMN_BORDER / 3);
			 
			 
			int rowIndex = ROW_BORDER;
			Iterator<Entity> entityIter = this.entities.iterator();
			while (entityIter.hasNext()) {
				 
				Entity ent = entityIter.next();
			 
				g2.setColor(Color.GREEN);
				g2.drawString(ent.toString(), ROW_BORDER / 3, rowIndex + (cellHeight / 2) );
			 
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
		
		String jsonText1 = "{'_metadata':{'name':'viral reproduction','id':123012,'type':'set'},'_name':'mouse:GO:0016032','_delim':'^','_active':1,'_elements':{'Hcfc1':'','Oas1a':'','Banf1':'','Smarcb1':'','Fv4':'','Bcl2':''}}";
		String jsonText2 = "{'_metadata':{'name':'viral reproduction','id':123012,'type':'set'},'_name':'mod1','_delim':'^','_active':1,'_elements':{'Hcfc1':'','Oas1a':'','Banf1':'','mod1':'','mod2':''}}";
		String jsonText3 = "{'_metadata':{'name':'viral reproduction','id':123012,'type':'set'},'_name':'mod2','_delim':'^','_active':1,'_elements':{'mod8':'','Oas1a':'','Banf1':'','mod7':'','mod3':'','Fv4':'','mod9':''}}";

		/*
		int ids1[] = {114, 115, 116};
		int ids2[] = {114, 117, 250};
		int ids3[] = {114, 116, 130};
		Set set1 = new Set(ids1);
		Set set2 = new Set(ids2);
		Set set3 = new Set(ids3);
		*/
		Set set1 = null;
		Set set2 = null;
		Set set3 = null;
		try {
			set1 = new Set(jsonText1);
			set2 = new Set(jsonText2);
			set3 = new Set(jsonText3);
		} catch (Exception e) {
			//
		}
		Set thesesets[] = {set1,set2,set3};
		
		
		SetEntityGrid grid = new SetEntityGrid(thesesets);
		grid.init();
		grid.makeGif();
	}
}
