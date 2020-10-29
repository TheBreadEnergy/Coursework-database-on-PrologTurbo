DOMAINS
	name, symptoms, healing = string
	id = integer
	intList = integer*
	file = f

DATABASE
	disease(id, name, symptoms, healing)

PREDICATES

	start
	openDefaultDB
	menu
	editMenu
	handleOption(string)
	editOption(string, id)
	option(string)
	opendb
	anyKey
	savedb
	rwrite(string)
	confirm
	confirmCheck(string)
	addDisease
	max(integer, integer, integer)
	findMax(intList, integer)
	maxAtList(intList, integer, integer)
	getMaxDiseaseId(id)
	getFreeDiseaseId(id, id)
	printAll(id, id)
	printAllDisease
	printDisease(id, name, symptoms, healing)
	printSingleDisease(id, name, symptoms, healing)
	print_to_excel
	readDisease(name, symptoms, healing)
	readDiseaseId(id)
	readNotEmptyString(string, string)
	removeDisease(id)
	removeAllDisease
	removeAll(id, id)


CLAUSES

	start :-
		openDefaultDB,
		makewindow(1, 2, 2, "Disease of St. Petersburg and the Leningrad region", 0, 0, 25, 80),
		menu.

	openDefaultDB :-
		existfile("DB.dbs"), !, consult("DB.dbs");
		openwrite(f, "DB.dbs"), closefile(f).

	menu :-
		clearwindow, nl,
		write("Enter a value from 0 to 10 to interact with the menu"), nl,nl,
		write("1 - Open database"), nl,
		write("2 - Show a disease"), nl,
		write("3 - Show all diseases"), nl,
		write("4 - Add disease"), nl,
		write("5 - Delete disease"), nl,
		write("6 - Edit disease"), nl,
		write("7 - Save database"), nl,
		write("8 - Remove database"),nl,
		write("9 - Export database to Excel"),nl,
		write("10 - Exit"),nl,nl,
		readln(Opt), handleOption(Opt).

	handleOption("10") :- !.
		handleOption(Option) :-
		clearwindow,
		option(Option),
		anyKey, menu.
	
	option("1") :-
		opendb.
	
	option("2") :-
		write("Enter disease's id: "),
		readint(Id),
		disease(Id, Name, Symptoms, Healing),
		clearwindow,
		printSingleDisease(Id, Name, Symptoms, Healing);
		write("Disease was not found\n").

	option("3") :-
		printAllDisease.

	option("4") :-
		addDisease.
	
	option("5") :-
		printAllDisease,
		readDiseaseId(Id),
		confirm,
		removeDisease(Id); !.
		
	option("6") :-
		editMenu.

	option("7") :-
		savedb.
	
	option("8") :-
		write("Remove all? "),nl,
		confirm,
		removeAllDisease,
		write("Removed").
	
	option("9") :-
		print_to_excel,
		write("Export completed!").
	
	option(_) :- write("Command was not found.\n").

	editMenu :-
		clearwindow,
		printAllDisease,
		write("Enter disease's id: "),
		readint(Id),
		disease(Id, Name, Symptoms, Healing), !,
		clearwindow,
		printSingleDisease(Id, Name, Symptoms, Healing),
		write("\n1 - Edit name\n"),
		write("2 - Edit symptoms\n"),
		write("3 - Edit healing\n"),
		write("0 - Cancel\n\n"),
		readln(Option),
		editOption(Option, Id);
		write("Disease was not found!\n").
	
	editOption("1", Id) :-
		disease(Id, _, Symptoms, Healing),
		readNotEmptyString(Name, "Name"),
		retract(disease(Id, _, _, _)),
		assertz(disease(Id, Name, Symptoms, Healing)),
		write("Edited\n").

	editOption("2", Id) :-
		disease(Id, Name, _, Healing),
		readNotEmptyString(Symptoms, "Symptoms"),
		retract(disease(Id, _, _, _)),
		assertz(disease(Id, Name, Symptoms, Healing)),
		write("Edited\n").

	editOption("3", Id) :-
		disease(Id, Name, Symptoms, _),
		readNotEmptyString(Healing, "Healing"),
		retract(disease(Id, _, _, _)),
		assertz(disease(Id, Name, Symptoms, Healing)),
		write("Edited\n").	

	anyKey :-
		write("\n\nPress any key to continue..."),
		readln(_).

	savedb:- 
		write("Enter file name to save the current database: "),
		readln(Fname), rwrite(Fname).
	
	rwrite(Fname):- 
		existfile(Fname), 
		write("A file with the same name already exists. Overwrite?"), nl,
		confirm,
		save(Fname),
		write("Database saved! ", Fname),nl, !.

	rwrite(Fname):- not(existfile(Fname)), save(Fname),
		write("Database saved! ", Fname),nl, !.

	rwrite(_):-
		write("Database was not saved"), nl.

	confirm :-
		makewindow(1, 2, 2, "Confirm your action", 10, 23, 5, 34),
		write("Y/y - Ok | Any key - Cancel: "),
		readln(Decision),
		removewindow,
		confirmCheck(Decision).
	
	confirmCheck("y") :- !.
	confirmCheck("Y") :- !.

	opendb:-
		write("Enter file name: "), readln(Name), nl,
		removeAllDisease,
		existfile(Name),
		consult(Name),
		write("Database loaded\n"), !;
		write("Database was not loaded"), nl.

	addDisease :-
		getFreeDiseaseId(1, Id),
		readDisease(Name, Symptoms, Healing),
		assertz(disease(Id, Name, Symptoms, Healing)),
		write("Added\n").

	getFreeDiseaseId(Id, Res) :- disease(Id, _, _, _),
		NextId = Id + 1,
		getFreeDiseaseId(NextId, Res).
	getFreeDiseaseId(Id, Id).
	
	getMaxDiseaseId(Res) :-
		findall(Id, disease(Id, _, _, _), Ids),
		findMax(Ids, Res).

	
	readDisease(Name, Symptoms, Healing) :-
		readNotEmptyString(Name, "name"),
		readNotEmptyString(Symptoms, "symptoms"),
		readNotEmptyString(Healing, "healing").
	
	readDiseaseId(Id) :-
		write("Enter disease's id: "),
		readint(Id), disease(Id, _, _, _), !;
		write("Disease with the id doesn't exist\n"), fail.
	
	readNotEmptyString(String, FieldName) :-
		nl,
		write(FieldName, ": "), readln(String), String <> "", !;
		write("Cannot be empty\n"), readNotEmptyString(String, FieldName).
	
	printAll(Id, MaxId) :-
		disease(Id, Name, Symptoms, Healing),
		printDisease(Id, Name, Symptoms, Healing),
		NextId = Id + 1, printAll(NextId, MaxId).
	printAll(Id, MaxId) :- Id <= MaxId,
		NextId = Id + 1, printAll(NextId, MaxId).
	printAll(_, _) :- !.

	printAllDisease :-
		getMaxDiseaseId(MaxId),
		printAll(1, MaxId).

	printDisease(Id, Name, Symptoms, Healing) :-
		write(Id), write(") "),
		write(Name), write(", "),
		write(Symptoms), write(", "),
		write(Healing), write("\n").

	printSingleDisease(Id, Name, Symptoms, Healing) :-
		write("Id: "), write(Id),
		write("\nName: "), write(Name),
		write("\nSymptoms: "), write(Symptoms),
		write("\nHealing: "), write(Healing),nl.
	
	removeDisease(Id) :-
		disease(Id, _, _, _),
		retract(disease(Id, _, _, _)).
	
	removeAllDisease :-
		getMaxDiseaseId(MaxId),
		removeAll(1, MaxId).

	removeAll(Id, MaxId) :-
		removeDisease(Id),
		NextId = Id + 1, removeAll(NextId, MaxId).
	removeAll(Id, MaxId) :- Id <= MaxId,
		NextId = Id + 1, removeAll(NextId, MaxId).
	removeAll(_, _) :- !.
	
	max(Left, Right, Max) :-
		Left > Right, Max = Left.
	max (_, Max, Max).

	findMax([], 1).
	findMax([H], H).
	findMax([H, HNext|T], Res) :-
		max(H, HNext, Max),
		maxAtList([Max|T], Max, Res).

	maxAtList([H], Max, Res) :- max(H, Max, Res).
	maxAtList([H, HNext|T], Max, Res) :-
		maxAtList([HNext|T], Max, NewMax),
		max(H, NewMax, Res).
	
	print_to_excel :-
		openwrite(f,"excel.csv"),writedevice(f),
		write("Id;"),
		write("Name;"),
		write("Symptoms;"),
		write("Healing;"),nl,
		disease(Id, Name, Symptoms, Healing),
		write(Id,";"),
		write(Name,";"),
		write(Symptoms,";"),
		write(Healing,";"),nl,fail;
		closefile(f).	

GOAL
	start.