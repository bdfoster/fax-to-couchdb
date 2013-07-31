--Fax processing for Freeswitch to  CouchDB on successful fax receipt

--Load Configuration
dofile("/usr/local/freeswitch/scripts/lua/fax-to-couchdb/config.lua");

--Load Required Modules
require "luchia";

--Call Variables
fax_tiff_filename = argv[1];
caller_id_name = argv[2];
caller_id_number = argv[3];
destination_number = argv[4];
fax_document_transferred_pages = argv[5];
fax_result_code = argv[6];
fax_result_text = argv[7];
fax_transfer_rate = argv[8];
fax_ecm_used = argv[9];
fax_bad_rows = argv[10];
call_uuid = argv[11];
timestamp = os.date("%Y-%m-%d-%H-%M-%S");
full_timestamp = os.date("%A, %B %d, %Y %R");
tmp_filepath = "/usr/local/freeswitch/storage/fax"

--Set the doc id
local doc_id = timestamp.."-"..caller_id_name;

--Set the database
database = "fax";
--Convert .tif to .pdf
fax_pdf_filename = timestamp.."-"..caller_id_name..".pdf";
pdf_conversion = os.execute("tiff2pdf -o "..tmp_filepath.."/"..fax_pdf_filename.." "..fax_tiff_filename);

--Build a new document object
local doc = luchia.document:new(database, server_params);
local contents = {
	Received = full_timestamp,
	From = caller_id_name.." <"..caller_id_number..">",
	To = destination_number,
	TotalPages = fax_document_transferred_pages,
	ResultCode = fax_result_code,
	ResultText = fax_result_text,
	TransferRate = fax_transfer_rate,
	EcmUsed = fax_ecm_used,
	BadRows = fax_bad_rows,
	CallUUID = call_uuid};

--Decide how to post to CouchDB based on result code of fax
local resp = doc:add_inline_attachment(tmp_filepath.."/"..fax_pdf_filename, "application/pdf", fax_pdf_filename, contents, doc_id);

--Figure out what to do after we attempt to POST to CouchDB
if doc:response_ok(resp) then 
	print("Fax posted to CouchDB successfully");
	os.execute("rm "..fax_tiff_filename);
	os.execute("rm "..tmp_filepath.."/"..fax_pdf_filename);	
else
	print("Fax NOT POSTED to CouchDB!");
	os.execute("rm "..tmp_filepath.."/"..fax_pdf_filename);
end;
