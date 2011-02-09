var selectCommit = function(a) {
	Controller.selectCommit_(a);
}

<<<<<<< HEAD
=======
// Relead only refs
var reload = function() {
	$("notification").style.display = "none";
	commit.reloadRefs();
	showRefs();
}

var showRefs = function() {
	var refs = $("refs");
	if (commit.refs) {
		refs.parentNode.style.display = "";
		refs.innerHTML = "";
		for (var i = 0; i < commit.refs.length; i++) {
			var ref = commit.refs[i];
			refs.innerHTML += '<span class="refs ' + ref.type() + (commit.currentRef == ref.ref ? ' currentBranch' : '') + '">' + ref.shortName() + '</span> ';
		}
	} else
		refs.parentNode.style.display = "none";
}

var loadCommit = function(commitObject, currentRef) {
	// These are only the things we can do instantly.
	// Other information will be loaded later by loadCommitDetails,
	// Which will be called from the controller once
	// the commit details are in.

	if (commit && commit.notificationID)
		clearTimeout(commit.notificationID);

	commit = new Commit(commitObject);
	commit.currentRef = currentRef;

	$("commitID").innerHTML = commit.sha;
	$("authorID").innerHTML = commit.author_name;
	$("subjectID").innerHTML = commit.subject.escapeHTML();
	$("diff").innerHTML = ""
	$("message").innerHTML = ""
	$("files").innerHTML = ""
	$("date").innerHTML = ""
	showRefs();

	for (var i = 0; i < $("commit_header").rows.length; ++i) {
		var row = $("commit_header").rows[i];
		if (row.innerHTML.match(/Parent:/)) {
			row.parentNode.removeChild(row);
			--i;
		}
	}

	// Scroll to top
	scroll(0, 0);

	if (!commit.parents)
		return;

	for (var i = 0; i < commit.parents.length; i++) {
		var newRow = $("commit_header").insertRow(-1);
		newRow.innerHTML = "<td class='property_name'>Parent:</td><td>" +
			"<a href='' onclick='selectCommit(this.innerHTML); return false;'>" +
			commit.parents[i].string + "</a></td>";
	}

	commit.notificationID = setTimeout(function() { 
		if (!commit.fullyLoaded)
			notify("Loading commit…", 0);
		commit.notificationID = null;
	}, 500);

}

var showDiff = function(is_big) {

	$("files").innerHTML = "";

	// Callback for the diff highlighter. Used to generate a filelist
	var newfile = function(name1, name2, id, mode_change, old_mode, new_mode) {
		var img = document.createElement("img");
		var p = document.createElement("p");
		var link = document.createElement("a");
		link.setAttribute("href", "#" + id);
		p.appendChild(link);
		var finalFile = "";
		if (name1 == name2) {
			finalFile = name1;
			img.src = "../../images/modified.png";
			img.title = "Modified file";
			p.title = "Modified file";
			if (mode_change)
				p.appendChild(document.createTextNode(" mode " + old_mode + " -> " + new_mode));
		}
		else if (name1 == "/dev/null") {
			img.src = "../../images/added.png";
			img.title = "Added file";
			p.title = "Added file";
			finalFile = name2;
		}
		else if (name2 == "/dev/null") {
			img.src = "../../images/removed.png";
			img.title = "Removed file";
			p.title = "Removed file";
			finalFile = name1;
		}
		else {
			img.src = "../../images/renamed.png";
			img.title = "Renamed file";
			p.title = "Renamed file";
			finalFile = name2;
			p.insertBefore(document.createTextNode(name1 + " -> "), link);
		}

		link.appendChild(document.createTextNode(finalFile.unEscapeHTML()));
		link.setAttribute("representedFile", finalFile);

		p.insertBefore(img, link);
		$("files").appendChild(p);
	}

	var binaryDiff = function(filename) {
		if (filename.match(/\.(png|jpg|icns|psd)$/i))
			return '<a href="#" onclick="return showImage(this, \'' + filename + '\')">Display image</a>';
		else
			return "Binary file differs";
	}
	
	highlightDiff(commit.diff, $("diff"), is_big, { "newfile" : newfile, "binaryFile" : binaryDiff });
}

>>>>>>> refs/remotes/ddlsmurf/development
var showImage = function(element, filename)
{
	element.outerHTML = '<img src="GitX://' + commit.sha + '/' + filename + '">';
	return false;
}

var showCommit = function(data){
	$("commit").innerHTML=data;
}

<<<<<<< HEAD
=======
var loadCommitDetails = function(data)
{
	commit.parseDetails(data);

	if (commit.notificationID)
		clearTimeout(commit.notificationID)
	else
		$("notification").style.display = "none";

	var formatEmail = function(name, email) {
		return email ? name + " &lt;<a href='mailto:" + email + "'>" + email + "</a>&gt;" : name;
	}

	$("authorID").innerHTML = formatEmail(commit.author_name, commit.author_email);
	$("date").innerHTML = commit.author_date;
	setGravatar(commit.author_email, $("author_gravatar"));

	if (commit.committer_name != commit.author_name) {
		$("committerID").parentNode.style.display = "";
		$("committerID").innerHTML = formatEmail(commit.committer_name, commit.committer_email);

		$("committerDate").parentNode.style.display = "";
		$("committerDate").innerHTML = commit.committer_date;
		setGravatar(commit.committer_email, $("committer_gravatar"));
	} else {
		$("committerID").parentNode.style.display = "none";
		$("committerDate").parentNode.style.display = "none";
	}

	$("message").innerHTML = commit.message.replace(/\n/g,"<br>");

	if (commit.diff.length < 200000)
		showDiff(false); /// !!!! FALSE
	else
		$("diff").innerHTML = "<a class='showdiff' href='' onclick='showDiff(true); return false;'>" +
			"This is a large commit (" + Math.round(commit.diff.length / 1024) + " kb). Click here or press 'v' to view.</a>";

	hideNotification();
	enableFeatures();
}
>>>>>>> refs/remotes/ddlsmurf/development
