package proteomecomparison.test;

import java.io.File;
import java.net.URL;
import java.util.Arrays;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.Map;

import junit.framework.Assert;

import org.ini4j.Ini;
import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Test;

import proteomecomparison.ProteomeComparisonParams;
import proteomecomparison.ProteomeComparisonResult;
import proteomecomparison.ProteomeComparisonServer;
import us.kbase.auth.AuthToken;
import us.kbase.common.service.JsonServerSyslog;
import us.kbase.common.service.RpcContext;
import us.kbase.common.service.UObject;
import us.kbase.common.service.Tuple4;
import us.kbase.workspace.CreateWorkspaceParams;
import us.kbase.workspace.ObjectSaveData;
import us.kbase.workspace.ProvenanceAction;
import us.kbase.workspace.SaveObjectsParams;
import us.kbase.workspace.WorkspaceClient;
import us.kbase.workspace.WorkspaceIdentity;

public class ProteomeComparisonServerTest {
    private static AuthToken token = null;
    private static Map<String, String> config = null;
    private static WorkspaceClient wsClient = null;
    private static String wsName = null;
    private static ProteomeComparisonServer impl = null;
    
    @BeforeClass
    public static void init() throws Exception {
        token = new AuthToken(System.getenv("KB_AUTH_TOKEN"));
        String configFilePath = System.getenv("KB_DEPLOYMENT_CONFIG");
        File deploy = new File(configFilePath);
        Ini ini = new Ini(deploy);
        config = ini.get("ProteomeComparison");
        wsClient = new WorkspaceClient(new URL(config.get("workspace-url")), token);
        wsClient.setAuthAllowedForHttp(true);
        // These lines are necessary because we don't want to start linux syslog bridge service
        JsonServerSyslog.setStaticUseSyslog(false);
        JsonServerSyslog.setStaticMlogFile(new File(config.get("scratch"), "test.log").getAbsolutePath());
        impl = new ProteomeComparisonServer();
    }
    
    private static String getWsName() throws Exception {
        if (wsName == null) {
            long suffix = System.currentTimeMillis();
            wsName = "test_ProteomeComparison_" + suffix;
            wsClient.createWorkspace(new CreateWorkspaceParams().withWorkspace(wsName));
        }
        return wsName;
    }
    
    private static RpcContext getContext() {
        return new RpcContext();

	    /*.withProvenance(Arrays.asList(new ProvenanceAction()
            .withService("ProteomeComparison").withMethod("please_never_use_it_in_production")
	    .withMethodParams(new ArrayList<UObject>())));*/
    }
    
    @AfterClass
    public static void cleanup() {
        if (wsName != null) {
            try {
                wsClient.deleteWorkspace(new WorkspaceIdentity().withWorkspace(wsName));
                System.out.println("Test workspace was deleted");
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }
    
    @Test
    public void testProteomeComparison() throws Exception {
        String objName = "genome.1";
        Map<String, Object> contig1 = new LinkedHashMap<String, Object>();
        contig1.put("id", "1");
        contig1.put("length", 10);
        contig1.put("md5", "md5");
        contig1.put("sequence", "agcttttcat");
        Map<String, Object> contig2 = new LinkedHashMap<String, Object>();
        contig2.put("id", "2");
        contig2.put("length", 5);
        contig2.put("md5", "md5");
        contig2.put("sequence", "agctt");
        Map<String, Object> contig3 = new LinkedHashMap<String, Object>();
        contig3.put("id", "3");
        contig3.put("length", 12);
        contig3.put("md5", "md5");
        contig3.put("sequence", "agcttttcatgg");
        Map<String, Object> obj = new LinkedHashMap<String, Object>();
        obj.put("contigs", Arrays.asList(contig1, contig2, contig3));
        obj.put("id", "id");
        obj.put("md5", "md5");
        obj.put("name", "name");
        obj.put("source", "source");
        obj.put("source_id", "source_id");
        obj.put("type", "type");
	obj.put("scientific_name","sn");
	obj.put("domain", "dm");
	obj.put("genetic_code", 1);
        Map<String, Object> feature = new LinkedHashMap<String, Object>();
	feature.put("type","CDS");
	feature.put("id", "id");
	feature.put("protein_translation","ABCD");
	feature.put("location", Arrays.asList(new Tuple4<String, Long, String, Long>().withE1("1").withE2(new Long(1)).withE3("+").withE4(new Long(10))));
	obj.put("features", Arrays.asList(feature));
        wsClient.saveObjects(new SaveObjectsParams().withWorkspace(getWsName()).withObjects(Arrays.asList(
                new ObjectSaveData().withType("KBaseGenomes.Genome").withName(objName).withData(new UObject(obj)))));
	String objName2 = "genome.2";
        wsClient.saveObjects(new SaveObjectsParams().withWorkspace(getWsName()).withObjects(Arrays.asList(
                new ObjectSaveData().withType("KBaseGenomes.Genome").withName(objName2).withData(new UObject(obj)))));
        ProteomeComparisonResult ret = impl.compareProteomes(new ProteomeComparisonParams().withOutputWs(getWsName()).withOutputId("pc.1").withGenome1ws(getWsName()).withGenome1id(objName).withGenome2ws(getWsName()).withGenome2id(objName2), token, getContext());
	ProteomeComparisonResult ret2 = impl.compareProteomes(new ProteomeComparisonParams().withOutputWs(getWsName()).withOutputId("pc.2").withGenome1ws("KBasePublicGenomesV5").withGenome1id("kb|g.490").withGenome2ws("KBasePublicGenomesV5").withGenome2id("kb|g.623"), token, getContext());
    }
}