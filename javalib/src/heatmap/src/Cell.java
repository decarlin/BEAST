import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.Rectangle;
import java.awt.geom.Rectangle2D;


public class Cell {
    
    private Rectangle2D.Double rect;
    private Set set;
    private Entity entity;
    // -1 to 1
    private double membershipValue = -2;
    
    // lazy instantiation
    private double getMembershipValue() {
        if (this.membershipValue < -1) {
            this.membershipValue = set.membershipValue(this.entity);
        }
        return this.membershipValue;
    }
    
    public Cell(double xstart, double ystart, double width, double height, Set set, Entity entity) {
        this.set = set;
        this.entity = entity;
        setCoordinates(xstart, ystart, width, height);
    }
    
    public String getEntityName() {
        return this.entity.getValue();
    }
    
    public double getCellIndex() {
        return rect.getMinY();
    }
    
    // rectangle of 
    public void setCoordinates(double xstart, double ystart, double width, double height) {
        this.rect = new Rectangle2D.Double(xstart, ystart, width, height);
    }
    
    public void drawCellToCanvas(Graphics2D g2, Color memberColor, Color neutral, Color antiMemberColor) {
        
        // fade to the level of membership value
        if (getMembershipValue() > 0) {
            g2.setColor(memberColor);
        } else if (getMembershipValue() == 0) {
            g2.setColor(neutral);
        } else {
            g2.setColor(antiMemberColor);
        }
    
        g2.fill(rect);
        //g2.setColor(Color.GRAY);
        g2.draw(this.rect);
    }

}
