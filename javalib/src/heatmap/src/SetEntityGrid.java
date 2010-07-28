import java.awt.*;

import org.json.*;

import java.awt.geom.AffineTransform;
import java.awt.geom.Rectangle2D;
import java.awt.image.BufferedImage;
import java.awt.image.Raster;
import java.io.BufferedReader;
import java.io.File;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;

import javax.imageio.ImageIO;
import javax.swing.JApplet;

public class SetEntityGrid extends JApplet {
	
	private static Color background;
	private static Grid grid;
    private final static int GRID_HEIGHT = 400;
    private final static int GRID_WIDTH = 800;
    private final static int ROW_BORDER = 0;
    private final static int COLUMN_BORDER = 0;
    
    private ArrayList<Set> sets = null;
    private ArrayList<Entity> entities = null;
    
    public SetEntityGrid(ArrayList<Set> newsets) {
    	
    	this.sets = new ArrayList<Set>();
    	this.entities = new ArrayList<Entity>();
    	
    	Iterator<Set> setsIter = newsets.iterator();
    	while (setsIter.hasNext()) {
    		
    		Set set = setsIter.next();
    		// add to the sets list
    		sets.add(set);
    		
    		// add the entities for this set that aren't already here
    		ArrayList<Entity> ents = set.getEntities();
    		Iterator<Entity> iter = ents.iterator();
    		while (iter.hasNext()) {
    			Entity newEnt = iter.next();
    			if (!this.entities.contains((Entity)newEnt)) {
    				this.entities.add((Entity)newEnt);
    			} else {
    				// increment the number of occurances of this entity
    				int index = this.entities.indexOf((Entity)newEnt);
    				this.entities.get(index).incrementNumOccurances();
    			}
    		}   		
    	}
    	
    	// sort entities by the number of occurances (reverse to get top ents on top)
    	EntityComparator ec = new EntityComparator();
    	Collections.sort(this.entities, ec);
    	Collections.reverse(this.entities);
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
    		File file = new File("heatmap.gif");
    		file.createNewFile();
    	    BufferedImage image =
    	        new BufferedImage(GRID_WIDTH, GRID_HEIGHT, BufferedImage.TYPE_INT_RGB);
    	    
    	    Graphics2D g2 = (Graphics2D)image.createGraphics();
        	this.grid.paintGrid(g2, Color.RED, Color.BLACK, Color.GREEN);
    	    
    	    ImageIO.write(image, "gif", file);
    	    g2.dispose();
    		
    	} catch (Exception e) {
    		
    		System.out.print("error!");
    	}
  
    }
    

    /*
     * Builds the 1x1 cell size grid of columns, each with a group of cells. 
     * 
     *
     */
    public void buildGrid() {
    	
		// math!
		int numColumns = this.sets.size();
		int numRows = this.entities.size();
		double cellWidth = (double)(GRID_WIDTH - ROW_BORDER) / (double)numColumns;
		double cellHeight = (double)(GRID_HEIGHT - COLUMN_BORDER)/ (double)numRows;		
    	
    	Iterator<Set> setsIter = this.sets.iterator();
    	  	 
    	Grid grid = new Grid();
    	
		double columnIndex = 0;
		while (setsIter.hasNext()) {
			
			// each set corresponds to a column
			Set set = (Set)setsIter.next();
			Column column = new Column(columnIndex);
			
			double rowIndex = 0;
			Iterator<Entity> entityIter = this.entities.iterator();
			while (entityIter.hasNext()) {
				
				// entity/set pairs correspond to a cell
				Entity ent = entityIter.next();
				Cell cell = new Cell(columnIndex, rowIndex, cellWidth, cellHeight, set, ent);
				
				column.addCell(cell);
				
				rowIndex = rowIndex + cellHeight;
			}		 
			grid.addColumn(column);
			
			columnIndex = columnIndex + cellWidth;			 
		}
		
		this.grid = grid;
    }
    
	/**
	 * @param args
	 */
	public static void main(String[] args) throws Exception{
		// TODO Auto-generated method stub
		
		/*
		Set newset1 = new Set((new JSONArray("[{'_metadata':{'name':'viral reproduction','id':123012,'type':'set'},'_name':'mod6','_delim':'^','_active':1,'_elements':{'mod8':'','Oas1a':'','Banf1':'','mod7':'','mod3':'','Fv4':'','mod81':''}}]")).getJSONObject(0));
		Set newset2 = new Set((new JSONArray("[{'_metadata':{'name':'viral reproduction','id':123012,'type':'set'},'_name':'mod6','_delim':'^','_active':1,'_elements':{'mod1':'','Oas1a':'','Banf1':'','mod12':'','mod3':'','Fv4':'','mod81':''}}]")).getJSONObject(0));

		ArrayList<Set> sets = new ArrayList<Set>();
		sets.add(newset1);
		sets.add(newset2);
		
		SetEntityGrid heatmap = new SetEntityGrid(sets);
		heatmap.init();
		heatmap.buildGrid();
		heatmap.makeGif();
		
		*/
		// read from standard inputs 
		
		
		ArrayList<Set> sets = new ArrayList<Set>();
		
		BufferedReader in = new BufferedReader(new InputStreamReader(System.in));
	    String line;
	   
	    JSONClassifier classifier = new JSONClassifier();
	    
	    while ((line = in.readLine()) != null && line.length() != 0) {
	    	try { 
	    		JSONArray arr1 = new JSONArray(line);
	    		JSONObject jsonObj = arr1.getJSONObject(0);
	    		int jsonType = classifier.classify(jsonObj);
	    		
	    		switch (jsonType) {
	    	
	    			case 1: sets.add(new Set(jsonObj));
	    		
	    		}
	    		
	    	} catch (Exception e) {
	    		System.out.println("Can't parse line:" + line);
	    		e.printStackTrace();
	    	}
	    }
	    	
		
		SetEntityGrid heatmap = new SetEntityGrid(sets);
		heatmap.init();
		heatmap.buildGrid();
		heatmap.makeGif();
		
	}
}
