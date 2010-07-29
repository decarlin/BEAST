import org.json.JSONObject;

public class JSONClassifier {
	
	private final static int types[] = { 1, 2 };
	
	public int classify(JSONObject jsonObj) {
		
		// sets classification
		try {
			JSONObject metas = jsonObj.getJSONObject("_metadata");
			String type = metas.getString("type");
			if (type.compareTo("set") == 0) {
				return types[0];
			} else if (type.compareTo("info") == 0) {
				return types[1];
			}
		} catch (Exception e) {
			//
		}
		

		return types[1];
	}

}
