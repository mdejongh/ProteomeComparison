package proteomecomparison;

import java.util.List;
import java.util.Map;

import us.kbase.common.service.Tuple11;
import us.kbase.workspace.ObjectData;
import us.kbase.workspace.ObjectIdentity;
import us.kbase.workspace.SaveObjectsParams;

public interface ObjectStorage {

	public List<ObjectData> getObjects(List<ObjectIdentity> objectIds) throws Exception;
    
    public List<Tuple11<Long, String, String, String, Long, String, Long, String, String, Long, Map<String,String>>> saveObjects(
    		SaveObjectsParams params) throws Exception;
}
