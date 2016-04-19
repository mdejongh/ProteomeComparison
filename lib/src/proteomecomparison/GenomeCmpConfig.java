package proteomecomparison;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.util.List;
import java.util.Map;
import java.util.Properties;

import org.ini4j.Ini;

import us.kbase.auth.AuthToken;
import us.kbase.auth.TokenFormatException;
import us.kbase.common.service.JsonClientException;
import us.kbase.common.service.Tuple11;
import us.kbase.common.service.UnauthorizedException;
import us.kbase.workspace.ObjectData;
import us.kbase.workspace.ObjectIdentity;
import us.kbase.workspace.SaveObjectsParams;
import us.kbase.workspace.WorkspaceClient;

public class GenomeCmpConfig {
    private File tempDir;
    private File blastBin;
    private ObjectStorage objectStorage;
	
	public GenomeCmpConfig(File tempDir, File blastBin, final WorkspaceClient wsClient) {
	    this.tempDir = tempDir;
	    this.blastBin = blastBin;
	    this.objectStorage = new ObjectStorage() {
			@Override
			public List<ObjectData> getObjects(List<ObjectIdentity> objectIds) throws Exception {
				return wsClient.getObjects(objectIds);
			}
			@Override
			public List<Tuple11<Long, String, String, String, Long, String, Long, String, String, Long, Map<String, String>>> saveObjects(
					SaveObjectsParams params) throws Exception {
			    return wsClient.saveObjects(params);
			}
		};
	}

	public File getTempDir() {
		return tempDir;
	}
	
	public File getBlastBin() {
		return blastBin;
	}
	
	public ObjectStorage getObjectStorage() {
		return objectStorage;
	}
}