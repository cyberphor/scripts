###
#
#   A Zeek script for detecting a watering hole attack.
# 
#   "Watering hole attack" - When a potentially malicious file is downloaded via HTTP and then, uploaded to an SMB share.
#
#   __author__ = 'Victor Fernandez III'
#   __version__ = '1.0'
#
###

# load Zeek's SMB framework of analyzers
@load policy/protocols/smb

# create some global variables
global hashes_all: set[string];
global hashes_downloaded_via_HTTP: set[string];
global hashes_uploaded_via_SMB: set[string];

# when you see a file
event file_new (f: fa_file) {

	# if the file was seen in HTTP or SMB traffic, hash it
	if (f$source == "HTTP" || f$source == "SMB") {
		Files::add_analyzer(f, Files::ANALYZER_MD5);
	}
}

# when you're asked to hash a file
event file_hash (f: fa_file, kind: string, hash: string) {

	# keep track of the hashed file
	add hashes_all[hash];
	
	# if the hashed file was seen in HTTP, track it as such
	if (f$source == "HTTP" && f$http$uri != "/") {
		add hashes_downloaded_via_HTTP[hash];
		print fmt ("[INFO] Connection: %s, Downloaded: %s, MD5: %s", f$http$uid, f$http$uri, hash);
	}

	# if the hashed file was seen in SMB, track it as such
	if (f$source == "SMB") {
		add hashes_uploaded_via_SMB[hash];
		
		# extract the connection uid
		for (con in f$conns) { local cid = f$conns[con]$uid; }
		
		# extract the connection data
		for (con in f$conns) { local cdata = f$conns[con]; }
		print fmt ("[INFO] Connection: %s, Uploaded: %s, MD5: %s", cid, f$info$filename, hash);

		# if the hashed file was seen in BOTH HTTP & SMB, alert me
		if (hash in hashes_downloaded_via_HTTP && hash in hashes_uploaded_via_SMB) {
			print fmt ("[ALERT] Possible watering hole attack in progress.");
			print fmt ("   -->  %s, MD5: %s", f$info$filename, hash);

			# and send the following info to 'notice.log'
			NOTICE([
				$note = Weird::Activity, 
				$msg = "Possible watering hole attack in progress.",
				$conn = cdata
			]);
		}
	}
}
