####################################################
# VMD Haddock Input Generator
# Sven Klumpe, July 2018
####################################################


#################################
# create haddock-EM input files
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


set HaddockPath "/home/sklumpe/chemistry_programs/Modelling/haddock2.4"
set freesasaPath "/usr/local/bin/freesasa"


proc haddock_em_docking {args} \
{
	return [eval ::HaddockInputGenerator::haddock_em_docking $args]
}



proc ::HaddockInputGenerator::haddock_em_docking {pdb1 pdb2 map res active initdock np} \
{
	global HaddockPath
	global freesasaPath
	exec python $HaddockPath/EMtools/em2xplor.py $map $map.xplor

	###############################
	#	CONFIGURATION
	###############################

	###############################
	#	INITIAL DOCKING??? 
	###############################

	if {$initdock != "on"} {
      puts "Performing Docking"
    } else {
		puts "No Initial Docking being performed"
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
	#	TBL FILE CREATION
	###############################

	exec -ignorestderr $freesasaPath --format=rsa $pdb1 > $pdb1.rsa
	exec -ignorestderr $freesasaPath --format=rsa $pdb2 > $pdb2.rsa
	exec awk "{if (NF==13 && (\$7>40 || \$9>40)) printf \"%s \",\$3; if (NF==14 && (\$8>40 || \$10>40)) printf \"%s \",\$4}" ${pdb1}.rsa > ${pdb1}_accessible.txt
	exec awk "{if (NF==13 && (\$7>40 || \$9>40)) printf \"%s \",\$3; if (NF==14 && (\$8>40 || \$10>40)) printf \"%s \",\$4}" ${pdb2}.rsa > ${pdb2}_accessible.txt
	exec paste -d " " ${pdb1}_accessible.txt ${pdb2}_accessible.txt > $pdb1-$pdb2-tmp.tbl


	if {$active == "none"} {
      	set script [open "active-tmp.txt" w]
		set command " "
		puts $script $command
		close $script
    } else {
		set script [open "active-tmp.txt" w]
		set active_res1 [atomselect 0 "${active} and name CA"]
		#puts $active_res1
		
		set active_res2 [atomselect 1 "${active} and name CA"]
		#puts $active_res2
		#set command " "
		puts -nonewline $script [$active_res1 get {resid}]
		puts $script [$active_res2 get {resid}]
		close $script
	}
	


	exec cat active-tmp.txt $pdb1-$pdb2-tmp.tbl > $pdb1-$pdb2.tbl
	exec rm active-tmp.txt
	exec rm $pdb1-$pdb2-tmp.tbl


	###############################
	#	RUNPARAM FILE CREATION
	###############################

	set segid1 [lindex [$pdb1_all get {segid}] 0]
	$pdb1_all set segid $segid1
	set segid2 [lindex [$pdb2_all get {segid}] 1]
	$pdb2_all set segid $segid2
	$pdb1_all writepdb segid_$pdb1
	$pdb2_all writepdb segid_$pdb2
	set runparam "run.param"
	set runfile [open $runparam "w"]
	puts $runfile "AMIB_TBL=$pdb1-$pdb2.tbl"
	puts $runfile "N_COMP=2"
	puts $runfile "PDB_FILE1=segid_$pdb1"
	puts $runfile "PDB_FILE2=segid_$pdb2"
	puts $runfile "PROJECT_DIR=./"
	puts $runfile "PROT_SEGID_1=$segid1"
	puts $runfile "PROT_SEGID_2=$segid2"
	puts $runfile "RUN_NUMBER=1"
	close $runfile



	###############################
	#	RUN HADDOCK2.4
	###############################
	
	exec $HaddockPath/haddock2.4 

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

	exec cd ./run1/
	exec $HaddockPath/haddock2.4 
}