####################################################
# VMD Haddock Input Generator
# Sven Klumpe, July 2018
####################################################


#################################
# create haddock-EM input files
# and run Haddock on local / cluster
# Sven Klumpe, July 2018
#################################

namespace eval ::HaddockInputGenerator {
    namespace export haddock_em_docking
	# Set up Variable
	set version 0.1
	set packageDescription "HaddockInputGenerator Plugin"

    # Variable for the path of the script
    variable home [file join [pwd] [file dirname [info script]]]
}
package provide HaddockInputGenerator $HaddockInputGenerator::version

set HaddockPath "/fs/pool/pool-sakata2/Sven/software/haddock/haddock2.4"
set HaddockEXE "$HaddockPath/Haddock/RunHaddock.py"
set freesasaPath "/fs/pool/pool-sakata2/Sven/software/haddock/freesasa-2.0.3/bin/freesasa"

##set HaddockPath "/home/sklumpe/chemistry_programs/Modelling/haddock2.4"
#set HaddockPath "/fs/pool/pool-sakata2/Sven/software/haddock/haddock2.4"
#set freesasaPath "/usr/local/bin/freesasa"


proc haddock_em_docking {args} \
{
	return [eval ::HaddockInputGenerator::haddock_em_docking $args]
}



proc ::HaddockInputGenerator::haddock_em_docking {pdb1 pdb2 map res active1 active2 initdock np pdblist} \
{
	global HaddockPath
	global freesasaPath
	global HaddockEXE
	global packagePath

  	set packagePath $::env(RosettaVMDDIR)
	###############################
	#	CONVERTING EM MAP
	###############################
	exec python $HaddockPath/EMtools/em2xplor.py $map $map.xplor

	###############################
	#	CONFIGURATION
	###############################

	###############################
	#	INITIAL DOCKING
	###############################

	if {$initdock != "on"} {
      puts "Performing Docking"

	  ## powerfit needs to go here!

    } else {
		puts "No Initial Docking being performed"
	}


    ###############################
	#	ROUTINE FOR LIST OF PDBS
	###############################  

	if {$pdblist == "none"} {
		puts "No PDB list given."
	} else {
		set pdblist_converted [regexp -all -inline {\S+} $pdblist]
		puts $pdblist_converted
		set number_of_structures [llength $pdblist_converted]

		set runparam "run.param"
    	set runfile [open $runparam "w"]
		puts $runfile "HADDOCK_DIR=$HaddockPath"
    	puts $runfile "N_COMP=$number_of_structures"
		puts $runfile "PROJECT_DIR=./"
		puts $runfile "CRYO-EM_FILE=$map.xplor"
		puts $runfile "RUN_NUMBER=1"


		set script [open "run.cns.patch" w]
		set patch_part0 "--- run.cns	2018-07-16 01:37:25.275873543 +0200
+++ run_backup.cns	2018-07-16 01:15:41.724127183 +0200
@@ -3358,89 +3358,89 @@
 
 {* Centroid definitions *}
 {+ choice: true false +}
-{===>} centroid_rest=false;
+{===>} centroid_rest=true;
 {===>} centroid_kscale=50.0;"
		puts $script $patch_part0

		set patch_part00 "
 {* Placement of centroids in absolute coordinates *}
-{===>} xcom_1=12.3;
-{===>} ycom_1=0.8;
-{===>} zcom_1=9.2;
-
-{===>} xcom_2=12.7;
-{===>} ycom_2=-3.4;
-{===>} zcom_2=29.7;
-
-{===>} xcom_3=0.0;
-{===>} ycom_3=0.0;
-{===>} zcom_3=0.0;
-
-{===>} xcom_4=0.0;
-{===>} ycom_4=0.0;
-{===>} zcom_4=0.0;
-
-{===>} xcom_5=0.0;
-{===>} ycom_5=0.0;
-{===>} zcom_5=0.0;
-
-{===>} xcom_6=0.0;
-{===>} ycom_6=0.0;
-{===>} zcom_6=0.0;
-
-{===>} xcom_7=0.0;
-{===>} ycom_7=0.0;
-{===>} zcom_7=0.0;
-
-{===>} xcom_8=0.0;
-{===>} ycom_8=0.0;
-{===>} zcom_8=0.0;
-
-{===>} xcom_9=0.0;
-{===>} ycom_9=0.0;
-{===>} zcom_9=0.0;
-
-{===>} xcom_10=0.0;
-{===>} ycom_10=0.0;
-{===>} zcom_10=0.0;
-
-{===>} xcom_11=0.0;
-{===>} ycom_11=0.0;
-{===>} zcom_11=0.0;
-
-{===>} xcom_12=0.0;
-{===>} ycom_12=0.0;
-{===>} zcom_12=0.0;
-
-{===>} xcom_13=0.0;
-{===>} ycom_13=0.0;
-{===>} zcom_13=0.0;
-
-{===>} xcom_14=0.0;
-{===>} ycom_14=0.0;
-{===>} zcom_14=0.0;
-
-{===>} xcom_15=0.0;
-{===>} ycom_15=0.0;
-{===>} zcom_15=0.0;
-
-{===>} xcom_16=0.0;
-{===>} ycom_16=0.0;
-{===>} zcom_16=0.0;
-
-{===>} xcom_17=0.0;
-{===>} ycom_17=0.0;
-{===>} zcom_17=0.0;
-
-{===>} xcom_18=0.0;
-{===>} ycom_18=0.0;
-{===>} zcom_18=0.0;
-
-{===>} xcom_19=0.0;
-{===>} ycom_19=0.0;
-{===>} zcom_19=0.0;
-
-{===>} xcom_20=0.0;
-{===>} ycom_20=0.0;
-{===>} zcom_20=0.0;"
		puts -nonewline $script $patch_part00

		set k 0
		foreach pdb_given $pdblist_converted {
			set name ""
			puts $pdb_given
			mol new $pdb_given
			set pdb_($k) [atomselect $k "all"]
			set suffix "_($k)"
			append name "pdb" $suffix
			lassign [measure center [set $name]] centroid{$k}x centroid{$k}y centroid{$k}z
			puts [set centroid{$k}x]
			

			set k1 [expr $k+1]
			set segid_given [lindex [[set $name] get {segid}] 0]
    		puts $runfile "PDB_FILE$k1=$pdb_given"
    		puts $runfile "PROT_SEGID_$k1=$segid_given"

			set patch_part$k1 "
+{===>} xcom_$k1=[set centroid{$k}x];
+{===>} ycom_$k1=[set centroid{$k}y];
+{===>} zcom_$k1=[set centroid{$k}z];
+"
			puts -nonewline $script [set patch_part[expr $k+1]]





			incr k
			#set segid [lindex [$pdb1_all get {segid}] 0] 
			#if {$segid == " "} {
			#	set segid_$k "A"
			#}



			# AIR might not make sense for many body docking...
			# Put AIR for molecules up to 6, else no AIR? This is how Bonvin provides it

			
			#exec -ignorestderr $freesasaPath --format=rsa $pdb_given > $pdb_given.rsa
			#exec awk "{if (NF==13 && (\$7>40 || \$9>40)) printf \"%s \",\$3; if (NF==14 && (\$8>40 || \$10>40)) printf \"%s \",\$4}" ${pdb_given}.rsa > ${pdb_given}_accessible.txt
			
		} 
		for {set j $k} {$j<20} {incr j} {
		set j1 [expr $j+1]
		if {$j == 19} {
			set patch_part$j1 "
+{===>} xcom_$j1=0.0;
+{===>} ycom_$j1=0.0;
+{===>} zcom_$j1=0.0;
"
		puts -nonewline $script [set patch_part$j1]
		} else {
			set patch_part$j1 "
+{===>} xcom_$j1=0.0;
+{===>} ycom_$j1=0.0;
+{===>} zcom_$j1=0.0;
+"
		puts -nonewline $script [set patch_part$j1]
		}
		
		}

		set patch_end "
 {* Are the centroid retraints ambiguous *}
 {+ choice: true false +}
@@ -3486,7 +3486,7 @@
 
 {* Density/XREF restraints *}
 {+ choice: true false +}
-{===>} em_rest=false;
+{===>} em_rest=true;
 {===>} em_kscale=15000;
 {+ choice: true false +}
 {===>} em_it0=true;
"
		puts -nonewline $script $patch_end
        #exec paste -d " " ${pdb1}_accessible.txt ${pdb2}_accessible.txt > $pdb1-$pdb2-tmp.tbl
		close $runfile
		close $script

	

	exec python $HaddockEXE
	exec patch ./run1/run.cns run.cns.patch


	puts "HADDOCK-EM DOCKING STARTED..."

    after 40000
    set pwd [exec pwd]
    set scriptsh [open "submission.sh" w]
        set submit "
source ${HaddockPath}/haddock_configure.sh
cd ${pwd}/run1/
HADDOCK=\"${HaddockPath}\"
\$(which python) \$HADDOCK/Haddock/RunHaddock.py
        "
    puts $scriptsh $submit
    close $scriptsh
    exec bash submission.sh

    puts "HADDOCK-EM DOCKING DONE!"

	break
		
	}
	
	###############################
	#	CALCULATE CENTROIDS
	###############################
	mol new $pdb1
	mol new $pdb2

	set pdb1_all [atomselect 0 "all"]
	set pdb2_all [atomselect 1 "all"]
	lassign [measure center $pdb1_all] centroid1x centroid1y centroid1z
	lassign [measure center $pdb2_all] centroid2x centroid2y centroid2z

	
	###############################
	#	GET SEGIDS
	###############################

	set segid1 [lindex [$pdb1_all get {segid}] 0]
	set segid2 [lindex [$pdb2_all get {segid}] 0]

	if {$segid1 == " "} {
		set segid1 "A"
	}
	if {$segid2 == " "} {
		set segid2 "B"
	}
	$pdb1_all set segid $segid1
	$pdb2_all set segid $segid2
	$pdb1_all writepdb segid_$pdb1
	$pdb2_all writepdb segid_$pdb2

	###############################
	#	TBL FILE CREATION
	###############################

	exec -ignorestderr $freesasaPath --format=rsa $pdb1 > $pdb1.rsa
	exec -ignorestderr $freesasaPath --format=rsa $pdb2 > $pdb2.rsa

	exec awk "{if (NF==13 && (\$7>40 || \$9>40)) printf \"%s \",\$3; if (NF==14 && (\$8>40 || \$10>40)) printf \"%s \",\$4}" ${pdb1}.rsa > ${pdb1}_accessible.txt
	exec awk "{if (NF==13 && (\$7>40 || \$9>40)) printf \"%s \",\$3; if (NF==14 && (\$8>40 || \$10>40)) printf \"%s \",\$4}" ${pdb2}.rsa > ${pdb2}_accessible.txt

	set passive1 [exec awk "{if (NF==13 && (\$7>40 || \$9>40)) printf \"%s \",\$3; if (NF==14 && (\$8>40 || \$10>40)) printf \"%s \",\$4}" ${pdb1}.rsa]
	set passive2 [exec awk "{if (NF==13 && (\$7>40 || \$9>40)) printf \"%s \",\$3; if (NF==14 && (\$8>40 || \$10>40)) printf \"%s \",\$4}" ${pdb2}.rsa]

	#exec paste -d " " ${pdb1}_accessible.txt ${pdb2}_accessible.txt > $pdb1-$pdb2-tmp.tbl


	if {$active1 == "none"} {
      	set script [open "active1-tmp.txt" w]
		set active1_parsed " "
		puts $script $active1_parsed
		close $script
    } else {
		set script [open "active1-tmp.txt" w]
		set active_res1 [atomselect 0 "${active1} and name CA"]
		puts $active_res1
		puts -nonewline $script [$active_res1 get {resid}]
		set active1_parsed [$active_res1 get {resid}]
		puts $active1_parsed
		close $script
	}
	if {$active2 == "none"} {
      	set script [open "active2-tmp.txt" w]
		set active2_parsed " "
		puts $script $active2_parsed
		close $script
    } else {
		set script [open "active2-tmp.txt" w]
		set active_res2 [atomselect 1 "${active2} and name CA"]
		puts [$active_res2 get {resid}]
		puts -nonewline $script [$active_res2 get {resid}]
		set active2_parsed [$active_res2 get {resid}]
		close $script
	}
	
	
	exec bash $packagePath/air_restraints_generator.sh "$active1_parsed" "$active2_parsed" "$passive1" "$passive2" "$segid1" "$segid2" "3.0" > $pdb1-$pdb2.tbl



	###############################
	#	RUNPARAM FILE CREATION
	###############################
	set runparam "run.param"
    set runfile [open $runparam "w"]
    puts $runfile "AMIB_TBL=$pdb1-$pdb2.tbl"
    puts $runfile "HADDOCK_DIR=$HaddockPath"
    puts $runfile "N_COMP=2"
    puts $runfile "PDB_FILE1=segid_$pdb1"
    puts $runfile "PDB_FILE2=segid_$pdb2"
    puts $runfile "PROJECT_DIR=./"
    puts $runfile "PROT_SEGID_1=$segid1"
    puts $runfile "CRYO-EM_FILE=$map.xplor"
    puts $runfile "PROT_SEGID_2=$segid2"
    puts $runfile "RUN_NUMBER=1"
    close $runfile


	#set runparam "run.param"
	#set runfile [open $runparam "w"]
	#puts $runfile "AMIB_TBL=$pdb1-$pdb2.tbl"
	#puts $runfile "N_COMP=2"
	#puts $runfile "PDB_FILE1=segid_$pdb1"
	#puts $runfile "PDB_FILE2=segid_$pdb2"
	#puts $runfile "PROJECT_DIR=./"
	#puts $runfile "PROT_SEGID_1=$segid1"
	#puts $runfile "PROT_SEGID_2=$segid2"
	#puts $runfile "RUN_NUMBER=1"
	#close $runfile



	###############################
	#	RUN HADDOCK2.4
	###############################
	exec python $HaddockEXE

	set script [open "run.cns.patch" w]
		set patch "
--- run.cns	2018-07-16 01:37:25.275873543 +0200
+++ run_backup.cns	2018-07-16 01:15:41.724127183 +0200
@@ -2899,7 +2899,7 @@
 
 {* Do you want to randomly exclude a fraction of the ambiguous restraints (AIRs)? *}
 {+ choice: true false +}
-{===>} noecv=true;
+{===>} noecv=false;
 
 {* Number of partitions for random exclusion (%excluded=100/number of partitions)? *}
 {===>} ncvpart=2;
@@ -3358,17 +3358,17 @@
 
 {* Centroid definitions *}
 {+ choice: true false +}
-{===>} centroid_rest=false;
+{===>} centroid_rest=true;
 {===>} centroid_kscale=50.0;
 
 {* Placement of centroids in absolute coordinates *}
-{===>} xcom_1=12.3;
-{===>} ycom_1=0.8;
-{===>} zcom_1=9.2;
-
-{===>} xcom_2=12.7;
-{===>} ycom_2=-3.4;
-{===>} zcom_2=29.7;
+{===>} xcom_1=[expr {double(round(100*$centroid1x))/100}];
+{===>} ycom_1=[expr {double(round(100*$centroid1y))/100}];
+{===>} zcom_1=[expr {double(round(100*$centroid1z))/100}];
+
+{===>} xcom_2=[expr {double(round(100*$centroid2x))/100}];
+{===>} ycom_2=[expr {double(round(100*$centroid2y))/100}];
+{===>} zcom_2=[expr {double(round(100*$centroid2z))/100}];
 
 {===>} xcom_3=0.0;
 {===>} ycom_3=0.0;
@@ -3486,7 +3486,7 @@
 
 {* Density/XREF restraints *}
 {+ choice: true false +}
-{===>} em_rest=false;
+{===>} em_rest=true;
 {===>} em_kscale=15000;
 {+ choice: true false +}
 {===>} em_it0=true;
		"

		puts $script $patch
		close $script

	exec patch ./run1/run.cns run.cns.patch

    ###############################
    #       RUN HADDOCK2.4 
    ###############################
    puts "HADDOCK-EM DOCKING STARTED..."

    after 40000
    set pwd [exec pwd]
    set scriptsh [open "submission.sh" w]
        set submit "
source ${HaddockPath}/haddock_configure.sh
cd ${pwd}/run1/
HADDOCK=\"${HaddockPath}\"
\$(which python) \$HADDOCK/Haddock/RunHaddock.py
        "
    puts $scriptsh $submit
    close $scriptsh
    exec bash submission.sh

    puts "HADDOCK-EM DOCKING DONE!"

	#exec cd ./run1/
	#exec $HaddockPath/haddock2.4 
}