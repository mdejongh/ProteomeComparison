/*
A KBase module: ProteomeComparison
*/

module ProteomeComparison {
    /* ProteomeComparison IS COPIED FROM THE GenomeComparison MODULE; AND THIS SERVICE CREATES A GenomeComparison.ProteomeComparison SO THAT WE DONT HAVE TO REFACTOR NARRATIVE CODE */

	/*
		string genome1ws - workspace of genome1
		string genome1id - id of genome1
		string genome2ws - workspace of genome2
		string genome2id - id of genome2
		float sub_bbh_percent - optional parameter, minimum percent of bit score compared to best bit score, default is 90
		string max_evalue -  optional parameter, maximum evalue, default is 1e-10
		string output_ws - workspace of output object
		string output_id - future id of output object
	*/
	typedef structure {
		string genome1ws;
		string genome1id;
		string genome2ws;
		string genome2id;
		float sub_bbh_percent;
		string max_evalue;
		string output_ws;
		string output_id;
	} ProteomeComparisonParams;

	typedef structure {
	    string report_name;
	    string report_ref;
	    string pc_ref;
	} ProteomeComparisonResult;

	funcdef compare_proteomes(ProteomeComparisonParams input) returns (ProteomeComparisonResult) authentication required;
};