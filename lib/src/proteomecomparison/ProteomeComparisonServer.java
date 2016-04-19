package proteomecomparison;

import java.io.File;
import us.kbase.auth.AuthToken;
import us.kbase.common.service.JsonServerMethod;
import us.kbase.common.service.JsonServerServlet;
import us.kbase.common.service.JsonServerSyslog;
import us.kbase.common.service.RpcContext;

//BEGIN_HEADER
import java.net.URL;
import java.util.Arrays;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.LinkedHashMap;

import us.kbase.common.service.Tuple11;
import us.kbase.common.service.UObject;
import us.kbase.kbasegenomes.Contig;
import us.kbase.kbasegenomes.ContigSet;
import us.kbase.workspace.ObjectIdentity;
import us.kbase.workspace.ObjectSaveData;
import us.kbase.workspace.ProvenanceAction;
import us.kbase.workspace.SaveObjectsParams;
import us.kbase.workspace.WorkspaceClient;
//END_HEADER

/**
 * <p>Original spec-file module name: ProteomeComparison</p>
 * <pre>
 * A KBase module: ProteomeComparison
 * </pre>
 */
public class ProteomeComparisonServer extends JsonServerServlet {
    private static final long serialVersionUID = 1L;

    //BEGIN_CLASS_HEADER
    private final String wsUrl;
    //END_CLASS_HEADER

    public ProteomeComparisonServer() throws Exception {
        super("ProteomeComparison");
        //BEGIN_CONSTRUCTOR
        wsUrl = config.get("workspace-url");
        //END_CONSTRUCTOR
    }

    /**
     * <p>Original spec-file function name: compare_proteomes</p>
     * <pre>
     * </pre>
     * @param   input   instance of type {@link proteomecomparison.ProteomeComparisonParams ProteomeComparisonParams}
     * @return   instance of type {@link proteomecomparison.ProteomeComparisonResult ProteomeComparisonResult}
     */
    @JsonServerMethod(rpc = "ProteomeComparison.compare_proteomes", async=true)
    public ProteomeComparisonResult compareProteomes(ProteomeComparisonParams input, AuthToken authPart, RpcContext jsonRpcContext) throws Exception {
        ProteomeComparisonResult returnVal = null;
        //BEGIN compare_proteomes
	WorkspaceClient wsClient = new WorkspaceClient(new URL(wsUrl), authPart);

	// this invokes blast, creates the ProteomeComparison, and saves it to the workspace
	BlastProteomes.run(input, new GenomeCmpConfig(new File("/tmp"), new File("blast/linux"), wsClient));

        Map<String, Object> reportObj = new LinkedHashMap<String, Object>();
	Map<String, Object> innerObj = new LinkedHashMap<String, Object>();
	String fullName = input.getOutputWs() + "/" + input.getOutputId();
	innerObj.put("ref", fullName);
	innerObj.put("description", "Proteome Comparison");
	reportObj.put("objects_created", Arrays.asList(innerObj));
	reportObj.put("text_message", "ProteomeComparison saved to " + fullName + "\n");
	String reportName = "proteome_comparison_report_"+input.getOutputId();
	wsClient.saveObjects(new SaveObjectsParams().withWorkspace(input.getOutputWs()).withObjects(Arrays.asList(new ObjectSaveData().withType("KBaseReport.Report").withName(reportName).withData(new UObject(reportObj)).withHidden(new Long(1)))));

	returnVal = new ProteomeComparisonResult().withReportName(reportName).withReportRef(input.getOutputWs() + "/" + reportName).withPcRef(fullName);
        //END compare_proteomes
        return returnVal;
    }

    public static void main(String[] args) throws Exception {
        if (args.length == 1) {
            new ProteomeComparisonServer().startupServer(Integer.parseInt(args[0]));
        } else if (args.length == 3) {
            JsonServerSyslog.setStaticUseSyslog(false);
            JsonServerSyslog.setStaticMlogFile(args[1] + ".log");
            new ProteomeComparisonServer().processRpcCall(new File(args[0]), new File(args[1]), args[2]);
        } else {
            System.out.println("Usage: <program> <server_port>");
            System.out.println("   or: <program> <context_json_file> <output_json_file> <token>");
            return;
        }
    }
}
